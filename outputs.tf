output "alb_dns_name" {
  value = module.network.alb_dns
}

output "kurakichi_sub_domain_name" {
  value = module.network.domain_name
}

output "ecs_lb" {
  value = module.container.ecs.load_balancer

}
