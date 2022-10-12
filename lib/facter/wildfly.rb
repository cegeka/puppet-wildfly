Facter.add(:current_wildfly_version) do
  confine :kernel => "Linux"

  setcode do
    wildfly_release = Facter::Util::Resolution.exec('/usr/bin/systemctl status wildfly | /usr/bin/grep Loaded')
    if /wildfly(\d+)/ =~ wildfly_release
       Facter.debug "Using systemctl and major version is : #{$1}"
       $1
    else
      begin
        path = File.readlink('/opt/wildfly')
        if /wildfly(\d+)/ =~ path
          Facter.debug "Using readlink and major version is : #{$1}"
          $1
        end
      rescue
        Facter.debug "Couldn't parse wildfly version - returning undef"
      end
    end

  end
end
