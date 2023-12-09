@description('Resources Group location')
param location string

@description('Resources tags')
param tags object = {}

@description('Service Name, must be an unique string without spaces, max lenght is 255 characters')
@minLength(1)
@maxLength(150)
param resourceName string

@secure()
param sqlServerAdminUsername string
@secure()
param sqlServerAdminPassword string

param skuName  string = 'Standard_D2ds_v4'

param storageSizeGB int = 128
param replicaCapacity int = 5
param serverVersion string = '14'
param availabilityZone string = '2'

param delegatedSubnetResourceId string
param privateDnsZoneArmResourceId string

resource flexibleServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: resourceName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: 'GeneralPurpose'
  }
  properties: {
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Enabled'
    }
    dataEncryption: {
      type: 'SystemManaged'
    }
    version: serverVersion
    administratorLogin: sqlServerAdminUsername
    administratorLoginPassword: sqlServerAdminPassword
    availabilityZone: availabilityZone
    storage: {
      storageSizeGB: storageSizeGB
    }
    backup: {
      backupRetentionDays: 30
      geoRedundantBackup: 'Disabled'
    }
    network: {
      delegatedSubnetResourceId: delegatedSubnetResourceId
      privateDnsZoneArmResourceId: privateDnsZoneArmResourceId
    }
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
    replicationRole: 'Primary'
    replicaCapacity: replicaCapacity
  }

  resource administrator 'administrators' = {
    name: '827b33ae-f661-4c17-8e3f-62d6591d95d0'
    properties: {
      principalType:'Group'
      principalName: 'database-global-administrators'
      tenantId: tenant().tenantId
    }
  }
}

// resource resourceName_application_name 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'application_name'
//   properties: {
//     source: 'system-default'
//   }
// }

// resource resourceName_archive_timeout 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'archive_timeout'
//   properties: {
//     value: '300'
//     source: 'system-default'
//   }
// }

// resource resourceName_array_nulls 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'array_nulls'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_analyze_scale_factor 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_analyze_scale_factor'
//   properties: {
//     value: '0.1'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_analyze_threshold 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_analyze_threshold'
//   properties: {
//     value: '50'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_freeze_max_age 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_freeze_max_age'
//   properties: {
//     value: '200000000'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_max_workers 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_max_workers'
//   properties: {
//     value: '3'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_multixact_freeze_max_age 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_multixact_freeze_max_age'
//   properties: {
//     value: '400000000'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_naptime 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_naptime'
//   properties: {
//     value: '60'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_vacuum_cost_delay 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_vacuum_cost_delay'
//   properties: {
//     value: '2'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_vacuum_cost_limit 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_vacuum_cost_limit'
//   properties: {
//     value: '-1'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_vacuum_insert_scale_factor 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_vacuum_insert_scale_factor'
//   properties: {
//     value: '0.2'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_vacuum_insert_threshold 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_vacuum_insert_threshold'
//   properties: {
//     value: '1000'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_vacuum_scale_factor 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_vacuum_scale_factor'
//   properties: {
//     value: '0.2'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_vacuum_threshold 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_vacuum_threshold'
//   properties: {
//     value: '50'
//     source: 'system-default'
//   }
// }

// resource resourceName_autovacuum_work_mem 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'autovacuum_work_mem'
//   properties: {
//     value: '-1'
//     source: 'system-default'
//   }
// }

// resource resourceName_azure_accepted_password_auth_method 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'azure.accepted_password_auth_method'
//   properties: {
//     value: 'md5'
//     source: 'system-default'
//   }
// }

// resource resourceName_azure_enable_temp_tablespaces_on_local_ssd 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'azure.enable_temp_tablespaces_on_local_ssd'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_azure_extensions 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'azure.extensions'
//   properties: {
//     source: 'system-default'
//   }
// }

// resource resourceName_backend_flush_after 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'backend_flush_after'
//   properties: {
//     value: '256'
//     source: 'system-default'
//   }
// }

// resource resourceName_backslash_quote 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'backslash_quote'
//   properties: {
//     value: 'safe_encoding'
//     source: 'system-default'
//   }
// }

// resource resourceName_bgwriter_delay 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'bgwriter_delay'
//   properties: {
//     value: '20'
//     source: 'system-default'
//   }
// }

// resource resourceName_bgwriter_flush_after 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'bgwriter_flush_after'
//   properties: {
//     value: '64'
//     source: 'system-default'
//   }
// }

// resource resourceName_bgwriter_lru_maxpages 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'bgwriter_lru_maxpages'
//   properties: {
//     value: '100'
//     source: 'system-default'
//   }
// }

// resource resourceName_bgwriter_lru_multiplier 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'bgwriter_lru_multiplier'
//   properties: {
//     value: '2'
//     source: 'system-default'
//   }
// }

// resource resourceName_bytea_output 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'bytea_output'
//   properties: {
//     value: 'hex'
//     source: 'system-default'
//   }
// }

// resource resourceName_check_function_bodies 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'check_function_bodies'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_checkpoint_completion_target 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'checkpoint_completion_target'
//   properties: {
//     value: '0.9'
//     source: 'system-default'
//   }
// }

// resource resourceName_checkpoint_timeout 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'checkpoint_timeout'
//   properties: {
//     value: '600'
//     source: 'system-default'
//   }
// }

// resource resourceName_checkpoint_warning 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'checkpoint_warning'
//   properties: {
//     value: '30'
//     source: 'system-default'
//   }
// }

// resource resourceName_client_encoding 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'client_encoding'
//   properties: {
//     value: 'UTF8'
//     source: 'system-default'
//   }
// }

// resource resourceName_client_min_messages 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'client_min_messages'
//   properties: {
//     value: 'notice'
//     source: 'system-default'
//   }
// }

// resource resourceName_commit_delay 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'commit_delay'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_commit_siblings 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'commit_siblings'
//   properties: {
//     value: '5'
//     source: 'system-default'
//   }
// }

// resource resourceName_connection_throttle_bucket_limit 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'connection_throttle.bucket_limit'
//   properties: {
//     value: '2000'
//     source: 'system-default'
//   }
// }

// resource resourceName_connection_throttle_enable 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'connection_throttle.enable'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_connection_throttle_factor_bias 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'connection_throttle.factor_bias'
//   properties: {
//     value: '0.8'
//     source: 'system-default'
//   }
// }

// resource resourceName_connection_throttle_hash_entries_max 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'connection_throttle.hash_entries_max'
//   properties: {
//     value: '500'
//     source: 'system-default'
//   }
// }

// resource resourceName_connection_throttle_reset_time 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'connection_throttle.reset_time'
//   properties: {
//     value: '120'
//     source: 'system-default'
//   }
// }

// resource resourceName_connection_throttle_restore_factor 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'connection_throttle.restore_factor'
//   properties: {
//     value: '2'
//     source: 'system-default'
//   }
// }

// resource resourceName_connection_throttle_update_time 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'connection_throttle.update_time'
//   properties: {
//     value: '20'
//     source: 'system-default'
//   }
// }

// resource resourceName_constraint_exclusion 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'constraint_exclusion'
//   properties: {
//     value: 'partition'
//     source: 'system-default'
//   }
// }

// resource resourceName_cpu_index_tuple_cost 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'cpu_index_tuple_cost'
//   properties: {
//     value: '0.005'
//     source: 'system-default'
//   }
// }

// resource resourceName_cpu_operator_cost 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'cpu_operator_cost'
//   properties: {
//     value: '0.0025'
//     source: 'system-default'
//   }
// }

// resource resourceName_cpu_tuple_cost 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'cpu_tuple_cost'
//   properties: {
//     value: '0.01'
//     source: 'system-default'
//   }
// }

// resource resourceName_cron_database_name 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'cron.database_name'
//   properties: {
//     value: 'postgres'
//     source: 'system-default'
//   }
// }

// resource resourceName_cron_log_run 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'cron.log_run'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_cron_log_statement 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'cron.log_statement'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_cron_max_running_jobs 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'cron.max_running_jobs'
//   properties: {
//     value: '32'
//     source: 'system-default'
//   }
// }

// resource resourceName_cursor_tuple_fraction 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'cursor_tuple_fraction'
//   properties: {
//     value: '0.1'
//     source: 'system-default'
//   }
// }

// resource resourceName_DateStyle 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'DateStyle'
//   properties: {
//     value: 'ISO, MDY'
//     source: 'system-default'
//   }
// }

// resource resourceName_deadlock_timeout 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'deadlock_timeout'
//   properties: {
//     value: '1000'
//     source: 'system-default'
//   }
// }

// resource resourceName_debug_pretty_print 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'debug_pretty_print'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_debug_print_parse 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'debug_print_parse'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_debug_print_plan 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'debug_print_plan'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_debug_print_rewritten 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'debug_print_rewritten'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_default_statistics_target 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'default_statistics_target'
//   properties: {
//     value: '100'
//     source: 'system-default'
//   }
// }

// resource resourceName_default_tablespace 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'default_tablespace'
//   properties: {
//     source: 'system-default'
//   }
// }

// resource resourceName_default_text_search_config 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'default_text_search_config'
//   properties: {
//     value: 'pg_catalog.english'
//     source: 'system-default'
//   }
// }

// resource resourceName_default_transaction_deferrable 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'default_transaction_deferrable'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_default_transaction_isolation 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'default_transaction_isolation'
//   properties: {
//     value: 'read committed'
//     source: 'system-default'
//   }
// }

// resource resourceName_default_transaction_read_only 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'default_transaction_read_only'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_effective_cache_size 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'effective_cache_size'
//   properties: {
//     value: '786432'
//     source: 'system-default'
//   }
// }

// resource resourceName_effective_io_concurrency 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'effective_io_concurrency'
//   properties: {
//     value: '1'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_bitmapscan 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_bitmapscan'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_gathermerge 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_gathermerge'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_hashagg 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_hashagg'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_hashjoin 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_hashjoin'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_indexonlyscan 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_indexonlyscan'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_indexscan 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_indexscan'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_material 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_material'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_mergejoin 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_mergejoin'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_nestloop 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_nestloop'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_partitionwise_aggregate 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_partitionwise_aggregate'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_partitionwise_join 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_partitionwise_join'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_seqscan 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_seqscan'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_sort 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_sort'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_enable_tidscan 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'enable_tidscan'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_escape_string_warning 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'escape_string_warning'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_exit_on_error 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'exit_on_error'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_extra_float_digits 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'extra_float_digits'
//   properties: {
//     value: '1'
//     source: 'system-default'
//   }
// }

// resource resourceName_force_parallel_mode 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'force_parallel_mode'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_from_collapse_limit 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'from_collapse_limit'
//   properties: {
//     value: '8'
//     source: 'system-default'
//   }
// }

// resource resourceName_geqo 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'geqo'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_geqo_effort 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'geqo_effort'
//   properties: {
//     value: '5'
//     source: 'system-default'
//   }
// }

// resource resourceName_geqo_generations 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'geqo_generations'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_geqo_pool_size 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'geqo_pool_size'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_geqo_seed 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'geqo_seed'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_geqo_selection_bias 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'geqo_selection_bias'
//   properties: {
//     value: '2'
//     source: 'system-default'
//   }
// }

// resource resourceName_geqo_threshold 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'geqo_threshold'
//   properties: {
//     value: '12'
//     source: 'system-default'
//   }
// }

// resource resourceName_gin_fuzzy_search_limit 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'gin_fuzzy_search_limit'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_gin_pending_list_limit 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'gin_pending_list_limit'
//   properties: {
//     value: '4096'
//     source: 'system-default'
//   }
// }

// resource resourceName_huge_pages 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'huge_pages'
//   properties: {
//     value: 'try'
//     source: 'system-default'
//   }
// }

// resource resourceName_idle_in_transaction_session_timeout 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'idle_in_transaction_session_timeout'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_intelligent_tuning 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'intelligent_tuning'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_intelligent_tuning_metric_targets 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'intelligent_tuning.metric_targets'
//   properties: {
//     value: 'none'
//     source: 'system-default'
//   }
// }

// resource resourceName_IntervalStyle 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'IntervalStyle'
//   properties: {
//     value: 'postgres'
//     source: 'system-default'
//   }
// }

// resource resourceName_jit 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'jit'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_jit_above_cost 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'jit_above_cost'
//   properties: {
//     value: '100000'
//     source: 'system-default'
//   }
// }

// resource resourceName_jit_inline_above_cost 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'jit_inline_above_cost'
//   properties: {
//     value: '500000'
//     source: 'system-default'
//   }
// }

// resource resourceName_jit_optimize_above_cost 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'jit_optimize_above_cost'
//   properties: {
//     value: '500000'
//     source: 'system-default'
//   }
// }

// resource resourceName_join_collapse_limit 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'join_collapse_limit'
//   properties: {
//     value: '8'
//     source: 'system-default'
//   }
// }

// resource resourceName_lc_monetary 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'lc_monetary'
//   properties: {
//     value: 'en_US.utf-8'
//     source: 'system-default'
//   }
// }

// resource resourceName_lc_numeric 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'lc_numeric'
//   properties: {
//     value: 'en_US.utf-8'
//     source: 'system-default'
//   }
// }

// resource resourceName_lo_compat_privileges 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'lo_compat_privileges'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_lock_timeout 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'lock_timeout'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_autovacuum_min_duration 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_autovacuum_min_duration'
//   properties: {
//     value: '-1'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_checkpoints 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_checkpoints'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_connections 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_connections'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_destination 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_destination'
//   properties: {
//     value: 'stderr'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_disconnections 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_disconnections'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_duration 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_duration'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_error_verbosity 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_error_verbosity'
//   properties: {
//     value: 'default'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_executor_stats 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_executor_stats'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_line_prefix 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_line_prefix'
//   properties: {
//     value: '%t-%c-'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_lock_waits 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_lock_waits'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_min_duration_statement 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_min_duration_statement'
//   properties: {
//     value: '-1'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_min_error_statement 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_min_error_statement'
//   properties: {
//     value: 'error'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_min_messages 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_min_messages'
//   properties: {
//     value: 'warning'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_replication_commands 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_replication_commands'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_statement 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_statement'
//   properties: {
//     value: 'none'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_statement_stats 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_statement_stats'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_log_temp_files 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'log_temp_files'
//   properties: {
//     value: '-1'
//     source: 'system-default'
//   }
// }

// resource resourceName_maintenance_work_mem 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'maintenance_work_mem'
//   properties: {
//     value: '216064'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_connections 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_connections'
//   properties: {
//     value: '859'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_locks_per_transaction 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_locks_per_transaction'
//   properties: {
//     value: '64'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_logical_replication_workers 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_logical_replication_workers'
//   properties: {
//     value: '4'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_parallel_maintenance_workers 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_parallel_maintenance_workers'
//   properties: {
//     value: '64'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_parallel_workers 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_parallel_workers'
//   properties: {
//     value: '8'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_parallel_workers_per_gather 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_parallel_workers_per_gather'
//   properties: {
//     value: '2'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_pred_locks_per_page 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_pred_locks_per_page'
//   properties: {
//     value: '2'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_pred_locks_per_relation 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_pred_locks_per_relation'
//   properties: {
//     value: '-2'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_prepared_transactions 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_prepared_transactions'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_replication_slots 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_replication_slots'
//   properties: {
//     value: '10'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_standby_archive_delay 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_standby_archive_delay'
//   properties: {
//     value: '30000'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_standby_streaming_delay 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_standby_streaming_delay'
//   properties: {
//     value: '30000'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_sync_workers_per_subscription 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_sync_workers_per_subscription'
//   properties: {
//     value: '2'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_wal_senders 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_wal_senders'
//   properties: {
//     value: '10'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_wal_size 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_wal_size'
//   properties: {
//     value: '1024'
//     source: 'system-default'
//   }
// }

// resource resourceName_max_worker_processes 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'max_worker_processes'
//   properties: {
//     value: '8'
//     source: 'system-default'
//   }
// }

// resource resourceName_metrics_autovacuum_diagnostics 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'metrics.autovacuum_diagnostics'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_metrics_collector_database_activity 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'metrics.collector_database_activity'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_metrics_pgbouncer_diagnostics 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'metrics.pgbouncer_diagnostics'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_min_parallel_index_scan_size 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'min_parallel_index_scan_size'
//   properties: {
//     value: '64'
//     source: 'system-default'
//   }
// }

// resource resourceName_min_parallel_table_scan_size 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'min_parallel_table_scan_size'
//   properties: {
//     value: '1024'
//     source: 'system-default'
//   }
// }

// resource resourceName_min_wal_size 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'min_wal_size'
//   properties: {
//     value: '80'
//     source: 'system-default'
//   }
// }

// resource resourceName_parallel_setup_cost 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'parallel_setup_cost'
//   properties: {
//     value: '1000'
//     source: 'system-default'
//   }
// }

// resource resourceName_parallel_tuple_cost 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'parallel_tuple_cost'
//   properties: {
//     value: '0.1'
//     source: 'system-default'
//   }
// }

// resource resourceName_password_encryption 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'password_encryption'
//   properties: {
//     value: 'md5'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_partman_bgw_analyze 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_partman_bgw.analyze'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_partman_bgw_dbname 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_partman_bgw.dbname'
//   properties: {
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_partman_bgw_interval 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_partman_bgw.interval'
//   properties: {
//     value: '3600'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_partman_bgw_jobmon 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_partman_bgw.jobmon'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_partman_bgw_role 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_partman_bgw.role'
//   properties: {
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_qs_index_generation_interval 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_qs.index_generation_interval'
//   properties: {
//     value: '15'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_qs_interval_length_minutes 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_qs.interval_length_minutes'
//   properties: {
//     value: '15'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_qs_is_enabled_fs 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_qs.is_enabled_fs'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_qs_max_plan_size 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_qs.max_plan_size'
//   properties: {
//     value: '7500'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_qs_max_query_text_length 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_qs.max_query_text_length'
//   properties: {
//     value: '6000'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_qs_query_capture_mode 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_qs.query_capture_mode'
//   properties: {
//     value: 'none'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_qs_retention_period_in_days 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_qs.retention_period_in_days'
//   properties: {
//     value: '7'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_qs_store_query_plans 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_qs.store_query_plans'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_qs_track_utility 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_qs.track_utility'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_stat_statements_max 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_stat_statements.max'
//   properties: {
//     value: '5000'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_stat_statements_save 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_stat_statements.save'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_stat_statements_track 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_stat_statements.track'
//   properties: {
//     value: 'top'
//     source: 'system-default'
//   }
// }

// resource resourceName_pg_stat_statements_track_utility 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pg_stat_statements.track_utility'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgaudit_log 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgaudit.log'
//   properties: {
//     value: 'none'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgaudit_log_catalog 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgaudit.log_catalog'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgaudit_log_client 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgaudit.log_client'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgaudit_log_level 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgaudit.log_level'
//   properties: {
//     value: 'log'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgaudit_log_parameter 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgaudit.log_parameter'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgaudit_log_relation 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgaudit.log_relation'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgaudit_log_statement_once 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgaudit.log_statement_once'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgaudit_role 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgaudit.role'
//   properties: {
//     source: 'system-default'
//   }
// }

// resource resourceName_pgbouncer_enabled 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgbouncer.enabled'
//   properties: {
//     value: 'false'
//     source: 'system-default'
//   }
// }

// resource resourceName_pglogical_batch_inserts 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pglogical.batch_inserts'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_pglogical_conflict_log_level 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pglogical.conflict_log_level'
//   properties: {
//     value: 'log'
//     source: 'system-default'
//   }
// }

// resource resourceName_pglogical_conflict_resolution 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pglogical.conflict_resolution'
//   properties: {
//     value: 'apply_remote'
//     source: 'system-default'
//   }
// }

// resource resourceName_pglogical_use_spi 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pglogical.use_spi'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgms_stats_is_enabled_fs 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgms_stats.is_enabled_fs'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgms_wait_sampling_history_period 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgms_wait_sampling.history_period'
//   properties: {
//     value: '100'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgms_wait_sampling_is_enabled_fs 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgms_wait_sampling.is_enabled_fs'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_pgms_wait_sampling_query_capture_mode 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'pgms_wait_sampling.query_capture_mode'
//   properties: {
//     value: 'none'
//     source: 'system-default'
//   }
// }

// resource resourceName_postgis_gdal_enabled_drivers 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'postgis.gdal_enabled_drivers'
//   properties: {
//     value: 'DISABLE_ALL'
//     source: 'system-default'
//   }
// }

// resource resourceName_quote_all_identifiers 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'quote_all_identifiers'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_random_page_cost 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'random_page_cost'
//   properties: {
//     value: '2'
//     source: 'system-default'
//   }
// }

// resource resourceName_require_secure_transport 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'require_secure_transport'
//   properties: {
//     value: 'OFF'
//     source: 'user-override'
//   }
// }

// resource resourceName_row_security 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'row_security'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_search_path 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'search_path'
//   properties: {
//     value: '"$user", public'
//     source: 'system-default'
//   }
// }

// resource resourceName_seq_page_cost 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'seq_page_cost'
//   properties: {
//     value: '1'
//     source: 'system-default'
//   }
// }

// resource resourceName_session_replication_role 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'session_replication_role'
//   properties: {
//     value: 'origin'
//     source: 'system-default'
//   }
// }

// resource resourceName_shared_buffers 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'shared_buffers'
//   properties: {
//     value: '262144'
//     source: 'system-default'
//   }
// }

// resource resourceName_shared_preload_libraries 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'shared_preload_libraries'
//   properties: {
//     value: 'pg_cron,pg_stat_statements'
//     source: 'user-override'
//   }
// }

// resource resourceName_ssl_max_protocol_version 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'ssl_max_protocol_version'
//   properties: {
//     source: 'system-default'
//   }
// }

// resource resourceName_ssl_min_protocol_version 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'ssl_min_protocol_version'
//   properties: {
//     value: 'TLSv1.2'
//     source: 'system-default'
//   }
// }

// resource resourceName_standard_conforming_strings 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'standard_conforming_strings'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_statement_timeout 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'statement_timeout'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_synchronize_seqscans 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'synchronize_seqscans'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_synchronous_commit 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'synchronous_commit'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_tcp_keepalives_count 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'tcp_keepalives_count'
//   properties: {
//     value: '9'
//     source: 'system-default'
//   }
// }

// resource resourceName_tcp_keepalives_idle 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'tcp_keepalives_idle'
//   properties: {
//     value: '120'
//     source: 'system-default'
//   }
// }

// resource resourceName_tcp_keepalives_interval 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'tcp_keepalives_interval'
//   properties: {
//     value: '30'
//     source: 'system-default'
//   }
// }

// resource resourceName_temp_buffers 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'temp_buffers'
//   properties: {
//     value: '1024'
//     source: 'system-default'
//   }
// }

// resource resourceName_temp_tablespaces 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'temp_tablespaces'
//   properties: {
//     value: 'temptblspace'
//     source: 'user-override'
//   }
// }

// resource resourceName_TimeZone 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'TimeZone'
//   properties: {
//     value: 'UTC'
//     source: 'system-default'
//   }
// }

// resource resourceName_track_activities 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'track_activities'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_track_activity_query_size 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'track_activity_query_size'
//   properties: {
//     value: '1024'
//     source: 'system-default'
//   }
// }

// resource resourceName_track_commit_timestamp 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'track_commit_timestamp'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_track_counts 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'track_counts'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_track_functions 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'track_functions'
//   properties: {
//     value: 'none'
//     source: 'system-default'
//   }
// }

// resource resourceName_track_io_timing 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'track_io_timing'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_transform_null_equals 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'transform_null_equals'
//   properties: {
//     value: 'off'
//     source: 'system-default'
//   }
// }

// resource resourceName_vacuum_cost_delay 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'vacuum_cost_delay'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_vacuum_cost_limit 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'vacuum_cost_limit'
//   properties: {
//     value: '200'
//     source: 'system-default'
//   }
// }

// resource resourceName_vacuum_cost_page_dirty 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'vacuum_cost_page_dirty'
//   properties: {
//     value: '20'
//     source: 'system-default'
//   }
// }

// resource resourceName_vacuum_cost_page_hit 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'vacuum_cost_page_hit'
//   properties: {
//     value: '1'
//     source: 'system-default'
//   }
// }

// resource resourceName_vacuum_cost_page_miss 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'vacuum_cost_page_miss'
//   properties: {
//     value: '2'
//     source: 'user-override'
//   }
// }

// resource resourceName_vacuum_defer_cleanup_age 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'vacuum_defer_cleanup_age'
//   properties: {
//     value: '0'
//     source: 'system-default'
//   }
// }

// resource resourceName_vacuum_freeze_min_age 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'vacuum_freeze_min_age'
//   properties: {
//     value: '50000000'
//     source: 'system-default'
//   }
// }

// resource resourceName_vacuum_freeze_table_age 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'vacuum_freeze_table_age'
//   properties: {
//     value: '150000000'
//     source: 'system-default'
//   }
// }

// resource resourceName_vacuum_multixact_freeze_min_age 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'vacuum_multixact_freeze_min_age'
//   properties: {
//     value: '5000000'
//     source: 'system-default'
//   }
// }

// resource resourceName_vacuum_multixact_freeze_table_age 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'vacuum_multixact_freeze_table_age'
//   properties: {
//     value: '150000000'
//     source: 'system-default'
//   }
// }

// resource resourceName_wal_buffers 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'wal_buffers'
//   properties: {
//     value: '2048'
//     source: 'system-default'
//   }
// }

// resource resourceName_wal_compression 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'wal_compression'
//   properties: {
//     value: 'on'
//     source: 'system-default'
//   }
// }

// resource resourceName_wal_level 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'wal_level'
//   properties: {
//     value: 'replica'
//     source: 'system-default'
//   }
// }

// resource resourceName_wal_receiver_status_interval 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'wal_receiver_status_interval'
//   properties: {
//     value: '10'
//     source: 'system-default'
//   }
// }

// resource resourceName_wal_writer_delay 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'wal_writer_delay'
//   properties: {
//     value: '200'
//     source: 'system-default'
//   }
// }

// resource resourceName_wal_writer_flush_after 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'wal_writer_flush_after'
//   properties: {
//     value: '128'
//     source: 'system-default'
//   }
// }

// resource resourceName_work_mem 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'work_mem'
//   properties: {
//     value: '4096'
//     source: 'system-default'
//   }
// }

// resource resourceName_xmlbinary 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'xmlbinary'
//   properties: {
//     value: 'base64'
//     source: 'system-default'
//   }
// }

// resource resourceName_xmloption 'Microsoft.DBforPostgreSQL/flexibleServers/configurations@2022-12-01' = {
//   parent: flexibleServer
//   name: 'xmloption'
//   properties: {
//     value: 'content'
//     source: 'system-default'
//   }
// }

// resource resourceName_azure_maintenance 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
//   parent: flexibleServer
//   name: 'azure_maintenance'
//   properties: {
//     charset: 'UTF8'
//     collation: 'en_US.utf8'
//   }
// }

// resource resourceName_azure_sys 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
//   parent: flexibleServer
//   name: 'azure_sys'
//   properties: {
//     charset: 'UTF8'
//     collation: 'en_US.utf8'
//   }
// }

// resource resourceName_hubmarketplace 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
//   parent: flexibleServer
//   name: 'hubmarketplace'
//   properties: {
//     charset: 'UTF8'
//     collation: 'en_US.utf8'
//   }
// }

// resource resourceName_omskeycloak 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
//   parent: flexibleServer
//   name: 'omskeycloak'
//   properties: {
//     charset: 'UTF8'
//     collation: 'en_US.utf8'
//   }
// }

// resource resourceName_postgres 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2022-12-01' = {
//   parent: flexibleServer
//   name: 'postgres'
//   properties: {
//     charset: 'UTF8'
//     collation: 'en_US.utf8'
//   }
// }
