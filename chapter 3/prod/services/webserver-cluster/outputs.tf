output "alb_dbs_name" {
  value = module.webserver_cluster.alb_dns_name
  description = "The domain name of the load balancer"
}