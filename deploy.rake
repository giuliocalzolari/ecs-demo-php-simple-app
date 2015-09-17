task :create_or_update do

  # Create a new task definition for this build
  taskDefintion = File.read(TASK_TEMPLATE)
  taskDefintion = taskDefintion.sub(/BUILD_NR/, VERSION)

  result = ecs.register_task_definition(family: TASK_FAMILY, container_definitions: JSON.parse(taskDefintion))
  fullQualifiedTaskDefinition = "#{TASK_FAMILY}:#{result.task_definition.revision}"

  if find_service(CLUSTER, SERVICE)
    puts "UPDATE SERVICE #{SERVICE} on cluster #{CLUSTER} using task definition #{fullQualifiedTaskDefinition}"
    result = ecs.update_service(cluster: CLUSTER, service: SERVICE, task_definition: fullQualifiedTaskDefinition, desired_count: DESIRED_COUNT)
  else
    puts "CREATE SERVICE #{SERVICE} on cluster #{CLUSTER} using task definition #{fullQualifiedTaskDefinition}"
    ecs.create_service(cluster: CLUSTER, service_name: SERVICE, task_definition: fullQualifiedTaskDefinition, desired_count: DESIRED_COUNT)
  end
end
