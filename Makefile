
SHELL := /bin/bash

# Environment Variables
# -----------------------------------------------------------------------------
ENV_FILE := .env

ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

# User Variables
# -----------------------------------------------------------------------------


# Colored Output
# -----------------------------------------------------------------------------
COLOR_RESET := \033[0m
COLOR_RED   := \033[0;31m
COLOR_GREEN := \033[0;32m
COLOR_BLUE  := \033[0;34m
COLOR_CYAN  := \033[36m


# Default Goal
# -----------------------------------------------------------------------------
.DEFAULT_GOAL := help

# Help
# -----------------------------------------------------------------------------
.PHONY: help
help:  ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} \
		/^[a-zA-Z_-]+:.*?##/ { \
			printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2 \
		} \
		/^##@/ { \
			printf "\n%s\n", substr($$0, 5) \
		} ' $(MAKEFILE_LIST)

##@ ArgoCD
# -----------------------------------------------------------------------------
.PHONY: argocd
argocd: ## Add ArgoCD 
	@echo -e "${COLOR_GREEN}Add ArgoCD...${COLOR_RESET}"
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

.PHONY: argocd-port-forward
argocd-port-forward: ## Port forward ArgoCD
	@echo -e "${COLOR_GREEN}Port forward ArgoCD...${COLOR_RESET}"
	kubectl port-forward svc/argocd-server -n argocd 8080:443

.PHONY: argocd-login
argocd-login: ## Login to ArgoCD
	@echo -e "${COLOR_GREEN}Login to ArgoCD...${COLOR_RESET}"
	argocd login localhost:8080 --insecure

.PHONY: argocd-get-password
argocd-get-password: ## Get ArgoCD password
	@echo -e "${COLOR_GREEN}Get ArgoCD password...${COLOR_RESET}"
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

.PHONY: argocd-get-server
argocd-get-server: ## Get ArgoCD server
	@echo -e "${COLOR_GREEN}Get ArgoCD server...${COLOR_RESET}"
	kubectl get svc argocd-server -n argocd

.PHONY: bootstrap
bootstrap: ## Get ArgoCD server
	argocd app create cluster-bootstrap \
		--dest-namespace argocd \
		--dest-server https://kubernetes.default.svc \
		--repo https://github.com/damianjankowski/cluster-playground.git \
		--path clusters/dev/cluster-bootstrap/
	kubectl create namespace monitoring
	argocd app sync cluster-bootstrap