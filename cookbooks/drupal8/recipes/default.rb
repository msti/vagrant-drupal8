project = "drupal8"

site = {
    'svrname'    => "#{project}.dev",
    'svraliases' => [ "www.#{project}.dev" ],
    'svrport'    => node['apache']['listen_ports'].to_a[0],
    'svrdocroot' => "/mnt/www",
    'dbusername' => "#{project}",
    'dbpassword' => "#{project}",
    'dbdatabase' => "#{project}",
    'drupalroot' => "/mnt/www/sites/default",
    'repository' => "http://git.drupal.org/project/drupal.git",
    'branch'     => "8.x"
}

root_database_connection = {
    :host => "localhost",
    :username => 'root',
    :password => node['mysql']['server_root_password']
}

#
# Prepare utilities.
#
package "libapache2-mod-php5" do
    action :install
end
package "php5-gd" do
    action :install
end
package "php5-mysql" do
    action :install
end
gem_package "compass" do
    action :install
end
gem_package "mysql" do
    action :install
end
apache_module "rewrite" do
    enable
end
apache_module "php5" do
    enable
end
php_pear "Console_Table" do
    action :install
end
php_pear_channel "pear.drush.org" do
    action :discover
end
php_pear "drush" do
    channel "pear.drush.org"
    action :install
end

#
# Set up site.
#
mysql_database site['dbdatabase'] do
    connection root_database_connection
    action :create
end
mysql_database_user site['dbusername'] do
    connection root_database_connection
    password site['dbpassword']
    database_name site['dbdatabase']
    privileges [:all]
    action :create
end
git site['svrdocroot'] do
    user "vagrant"
    group "vagrant"
    repository "#{site['repository']}"
    reference "#{site['branch']}"
    action :sync
end
web_app site['svrname'] do
    server_name site['svrname']
    server_aliases site['svraliases']
    allow_override "All"
    docroot site['svrdocroot']
end