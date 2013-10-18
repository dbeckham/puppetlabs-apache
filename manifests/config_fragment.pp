# Define: apache::config_fragment
#
# Inserts a custom configuration fragment
# into the Apache config at the 'server config' level.
#
# To ensure they don't interfere with normal operations,
# fragments are written to the confd_dir with the following pattern:
#   ${priority}_conf_fragment_${title}
#
# Parameters:
# - The $content of the config file; only one of $content or $source can be defined
# - A $source file URI or local path to be copied into place
# - The $priority of the configuration fragment
#
# Actions:
# - Creates custom configuration fragments
#
# Requires:
# - The apache class
#
# Sample Usage:
#
#  # Very Simple Usage:
#  apache::config_fragment{ 'no_etag':
#    content => 'FileETag None'
#  }
#
#  # Using a custom config template
#  apache::config_fragment{ 'my_custom_config':
#    content  => template('apache/my_custom_config.erb'),
#    priority => 25
#  }
#
#  # Using a custom config file
#  apache::config_fragment{ 'my_custom_config':
#    source   => 'puppet:///modules/apache/my_custom_config.conf',
#    priority => 25
#  }
#
define apache::config_fragment (
  $content  = undef,
  $source   = undef,
  $priority = 10,
){

  # The base class must be included first because it is used by parameter defaults
  if ! defined(Class['apache']) {
    fail('You must include the apache base class before using any apache defined resources')
  }

  # Either $content or $source must exist, but not both
  if ! $content and ! $source {
    fail("Apache::Config_fragment[${title}]: must pass either 'content' or 'source' parameters for custom config fragment")
  }

  if $content and $source {
    fail("Apache::Config_fragment[${title}]: 'content' and 'source' cannot be defined at the same time")
  }

  $filename = regsubst("${priority}_conf_fragment_${title}.conf", ' ', '_', 'G')

  file { $filename:
    ensure  => "file",
    path    => "${apache::confd_dir}/$filename",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content,
    source  => $source,
    require => Exec["mkdir ${apache::confd_dir}"],
    before  => File[$apache::confd_dir],
    notify  => Service['httpd'],
  }

}
