property :scrape_interval,     String
property :scrape_timeout,      String
property :labels,              Hash
property :target,              [Array, String]
property :metrics_path,        String, default: '/metrics'

default_action :create

action :create do
  with_run_context :root do
    edit_resource(:template, node['prometheus']['flags']['config.file']) do |new_resource|
      variables[:jobs] ||= {}
      variables[:jobs][new_resource.name] ||= {}
      variables[:jobs][new_resource.name]['scrape_interval'] = new_resource.scrape_interval
      variables[:jobs][new_resource.name]['scrape_timeout'] = new_resource.scrape_timeout
      variables[:jobs][new_resource.name]['target'] = new_resource.target
      variables[:jobs][new_resource.name]['metrics_path'] = new_resource.metrics_path
      variables[:jobs][new_resource.name]['labels'] = new_resource.labels

      action :nothing
      delayed_action :create

      not_if { node['prometheus']['allow_external_config'] }
    end
  end
end

action :delete do
  template node['prometheus']['flags']['config.file'] do
    action :delete
  end
end
