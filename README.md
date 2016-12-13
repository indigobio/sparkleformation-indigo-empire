## sparkleformation-indigo-empire

Contains a sparkleformation template and an ansible playbook that, together, create members of an Empire cluster.

### Sparkleformation

| Parameter | Default Value | Purpose |
|-----------|---------------|---------|
| AnsibleVersion | 2.2.0.0-1ppa | Version of Ansible to install |
| ControllerAnsibleLocalYamlPath | local.yml | Path to ansible's local.yml file |
| ControllerAnsiblePlaybookBranch | master | Branch of git repository to clone |
| ControllerAnsiblePlaybookRepo | None | URL of this git repository |
| ControllerAssociatePublicIpAddress | false | No reason to change this |
| ControllerDesiredCapacity | 1 | Increase to create more controllers.  Recommend setting to 2. |
| ControllerDomainName | `ENV['public_domain']` | The public domain of the environment | 
| ControllerElbName | `ENV['org']`-`ENV['environment']`-empire-elb | No reason to change |
| ControllerInstanceMonitoring | false | Set to true to enable detailed cloudwatch monitoring (additional costs apply) |
| ControllerInstanceType | t2.small | Controls the size of each controller instance | 
| ControllerMaxSize | 1 | Increase to allow more controllers.  Recommend setting to 2. |
| ControllerMinSize | 0 | Minimum allowable number of Empire controllers |
| ControllerNotificationTopic | automatically determined | No need to change |
| ControllerRecord | empire.`ENV['public_domain']` | No need to change |
| ControllerRootVolumeSize | 12 | The root (/) volume size on the controller | 
| ControllerTtl | 60 | The TTL of the empire.`ENV['public_domain']` DNS record |
| DockerEmail | none | The e-mail of our Docker registry deployment user's account |
| DockerPass | none | The password of our Docer registry deployment user's account |
| ElbSecurityPolicy | latest | No reason to change | 
| EmpireDatabasePassword | none | The password of the Empire RDS instance's non-privileged user account |
| EmpireDatabaseUser | none | The name of the Empire RDS instance's non-privileged user account |
| EmpireTokenSecret | random | ?? |
| EmpireVersion | 0.10.0 | The version of the remind101/empire docker image to run |
| EnableSumologic | true | Enables sumologic |
| GithubClientId | none | The github client that has access to Empire's API |
| GithubClientSecret | none | Secret for the github client that has access to Empire's API |
| GithubOrganization | indigobio | The github organization that has been granted access to Empire's API |
| MinionAnsibleLocalYamlPath | local.yml | Path to ansible's local.yml file |
| MinionAnsiblePlaybookBranch | master | Branch of git repository to clone |
| MinionAnsiblePlaybookRepo | None | URL of this git repository |
| MinionAssociatePublicIpAddress | false | No reason to change this |
| MinionDesiredCapacity | 1 | Increase to create more minions.  Recommend setting to 2. |
| MinionDomainName | `ENV['public_domain']` | The public domain of the environment | 
| MinionElbName | `ENV['org']`-`ENV['environment']`-empire-elb | No reason to change |
| MinionInstanceMonitoring | false | Set to true to enable detailed cloudwatch monitoring (additional costs apply) |
| MinionInstanceType | t2.small | Controls the size of each minion instance | 
| MinionMaxSize | 1 | Increase to allow more minions.  Recommend setting to 2. |
| MinionMinSize | 0 | Minimum allowable number of Empire minions |
| MinionNotificationTopic | automatically determined | No need to change |
| MinionRecord | empire.`ENV['public_domain']` | No need to change |
| MinionRootVolumeSize | 12 | The root (/) volume size on the minion | 
| MinionTtl | 60 | The TTL of the empire.`ENV['public_domain']` DNS record |
| NewRelicLicenseKey | ENV['new_relic_license_key'] | The New Relic API license key |
| NewRelicServerLabels | none | A comma-delimited set of colon-separated Key/Value pairs |
| SshKeyPair | indigo-bootstrap | The SSH key to use for each instance's 'ubuntu' account |
| SumologicAccessId | `ENV['sumologic_access_id']` | SumoLogic credentials | 
| SumologicAccessKey | `ENV['sumologic_access_key']` | SumoLogic credentials | 
| SumologicCollectorName | none | The instance's fully qualified hostname if left blank |
| Vpc | automatically determined | cannot change |

### Troubleshooting

Loose notes.

/var/lib/cfn-init/data/metadata.json = whatever comes over the wire from cfn-init.
/var/lib/cloud/instance/user-data = minimal, these days.  mostly kicks off commands in /var/lib/cfn-init/data/metadata.json
