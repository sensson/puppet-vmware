class vmware {
	# detect if this is a vmware guest because we only want to install it if it is
	case $virtual {
		'vmware': {
			# set the package names that we need to install
			$vmware_tools 	= [ "vmware-tools-esx-nox" ]
			
			# import the ssh keys for vmware
			exec { 'yum-importkey-vmware-rsa':
				command			=> "/bin/rpm --import http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub",
				unless			=> "/bin/rpm -qa | /bin/grep -c gpg-pubkey-66fd4949-4803fe57",
				before			=> Yumrepo['vmware'],
			}
			exec { 'yum-importkey-vmware-dsa':
				command			=> "/bin/rpm --import http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub",
				unless			=> "/bin/rpm -qa | /bin/grep -c gpg-pubkey-04bbaa7b-4c881cbf",
				before			=> Yumrepo['vmware'],
			}

			# determine the OS before installing vmware tools
			$vmware_baseurl = "http://packages.vmware.com/tools/esx/5.5/rhel\$releasever/\$basearch/"
        	
			# make sure the yum repo is added before we can install vmware tools
			yumrepo { vmware:
				descr		 	=> "VMware Tools Repository",
				enabled			=> 1,
				gpgcheck		=> 1,
				baseurl			=> $vmware_baseurl
			} ->
        	
			# make sure the packages are installed
			package { $vmware_tools:
				ensure 			=> latest      	
			} ->
			exec { "start vmtoolsd":
				command => "/sbin/initctl start vmware-tools-services",
				unless => "/usr/bin/pgrep vmtoolsd",
			}
		}
	}
}