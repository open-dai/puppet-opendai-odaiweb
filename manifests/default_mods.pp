class odaiweb::default_mods {
  case $::osfamily {
    'debian': {
      include apache::mod::cgid # Debian uses mpm_worker
      include apache::mod::reqtimeout
    }
    'redhat': {
      include apache::mod::cgi # RedHat uses mpm_prefork
      include apache::mod::cache
      include apache::mod::disk_cache
      include apache::mod::info
      include apache::mod::ldap
      include apache::mod::mime_magic
      include apache::mod::proxy
      include apache::mod::proxy_http
      include apache::mod::proxy_html
      include apache::mod::userdir
      apache::mod { 'actions': }
      apache::mod { 'auth_digest': }
      apache::mod { 'authn_alias': }
      apache::mod { 'authn_anon': }
      apache::mod { 'authn_dbm': }
      apache::mod { 'authn_default': }
      apache::mod { 'authnz_ldap': }
      apache::mod { 'authz_dbm': }
      apache::mod { 'authz_owner': }
      apache::mod { 'expires': }
      apache::mod { 'ext_filter': }
      apache::mod { 'include': }
      apache::mod { 'logio': }
      apache::mod { 'proxy_ajp': }
      apache::mod { 'proxy_connect': }
      apache::mod { 'proxy_ftp': }
      apache::mod { 'rewrite': }
      apache::mod { 'speling': }
      apache::mod { 'substitute': }
      apache::mod { 'suexec': }
      apache::mod { 'usertrack': }
      apache::mod { 'version': }
      apache::mod { 'vhost_alias': }
    }
  }

  include apache::mod::alias
  include apache::mod::autoindex
  include apache::mod::dav
  include apache::mod::dav_fs
  include apache::mod::deflate
  include apache::mod::dir
  include apache::mod::mime
  include apache::mod::negotiation
  include apache::mod::setenvif
  include apache::mod::status
  apache::mod { 'auth_basic': }
  apache::mod { 'authn_file': }
  apache::mod { 'authz_default': }
  apache::mod { 'authz_groupfile': }
  apache::mod { 'authz_user': }
  apache::mod { 'env': }
}
