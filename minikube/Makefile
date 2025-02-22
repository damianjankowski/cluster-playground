.SHELLFLAGS = -e

ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif


# Default target
.PHONY: all
all: help ## Show this help message

.PHONY: help
help: ## Show available commands
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?##"} \
	/^##@/ {print "\n" substr($$0, 5)} \
	/^[a-zA-Z0-9_-]+:.*?##/ {printf "  make %-20s - %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Minikube
##@ Minikube
.PHONY: setup-minikube
setup-minikube: ## Setup Minikube cluster
	minikube start --cpus=4 --memory=10900 -v=2
	minikube update-context

.PHONY: watch-pods
watch-pods: ## Watch
	watch kubectl get po -A

# o11y
##@ o11y
.PHONY: kiali
kiali: ## Open Kiali dashboard
	nohup istioctl dash kiali > /dev/null 2>&1 &

.PHONY: grafana
grafana: ## Open Grafana dashboard
	nohup istioctl dash grafana > /dev/null 2>&1 &

.PHONY: prometheus
prometheus: ## Open Prometheus dashboard
	nohup istioctl dash prometheus > /dev/null 2>&1 &

.PHONY: jaeger
jaeger: ## Open Jaeger dashboard
	nohup istioctl dash jaeger > /dev/null 2>&1 &

.PHONY: dashes
dashes: kiali grafana prometheus jaeger ## Open all dashboards
	@echo "All dashboards opened in the background. Access them via:"
	@echo " - Kiali: http://localhost:20001/kiali"
	@echo " - Grafana: http://localhost:3000"
	@echo " - Prometheus: http://localhost:9090"
	@echo " - Jaeger: http://localhost:16686"

# istio
##@ istio
.PHONY: tunnel
tunnel: ## Enable Istio ingress tunnel
	minikube tunnel

.PHONY: test-tunnel
test-tunnel: ## Check Istio ingress response
	curl localhost:80 -vvv

# Skaffold
##@ Skaffold
.PHONY: run
run: ## Skaffold run
	skaffold run

.PHONY: redeploy
redeploy: prune run ## Skaffold delete
	echo "Done"

.PHONY: log
log: ## Skaffold log
	skaffold run --tail

# General
##@ General
.PHONY: create ## Create env
create: setup-minikube run dashes## Setup Minikube cluster
	echo "🚀  Lets get the party started! Setup completed"

.PHONY: prune
prune: ## Prune them all!
	@echo "🔥  Prune Skaffold deployments..."
	skaffold delete || true

	@echo "🔥  Prune  Istio namespaces..."
	kubectl delete namespace istio-system --ignore-not-found=true || true
	kubectl delete namespace istio-ingress --ignore-not-found=true || true
	kubectl delete namespace databases --ignore-not-found=true || true

	@echo "🔥  Prune  all Istio CRD"
	crds=$$(kubectl get crds | grep 'istio.io' | awk '{print $$1}'); \
	if [ -n "$$crds" ]; then \
		kubectl delete crd $$crds --ignore-not-found=true || true; \
	else \
		echo "No Istio CRD found."; \
	fi

	@echo "🔥  Checking remaining pods"
	kubectl get pods -A || true

	@echo "🔥  Prune Minikube cluster"
	minikube delete || true

	@echo "🔥  Cleanup complete!"

# General
##@ General
.PHONY: db ## Create env
db: ## DB port forward
	kubectl port-forward customers-db-mysql-0 56478:3306 -n default
