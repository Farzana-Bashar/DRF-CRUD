NAMESPACE ?= default
IMG_NAME ?= server-dashboard

# version based tags
# denotes a tag originated from last annotated tag

STG_TAG ?= 5

# denotes a proper tag, used for production image tagging


# projects

STG_PROJECT ?= myalice-stg
# image paths
AWS_REGISTRY_HOST ?= 525057155055.dkr.ecr.ap-southeast-1.amazonaws.com
STG_IMG_PATH ?= ${AWS_REGISTRY_HOST}/${IMG_NAME}


# images
STG_IMG ?= ${STG_IMG_PATH}:${STG_TAG}

.PHONY: publish_dev
publish_dev: build_dev
	@ echo "Publishing image to dev registry"
	@ docker push ${STG_IMG}
	@ echo "Done publishing: ${STG_IMG}"

# docker image build tasks
# the same built image will be used by staging and production env as well
.PHONY: build_stage
build_dev:
	@ echo "Building stage docker image ${STG_IMG}"
	@ docker build -t ${STG_IMG} .
# end - docker image build tasks

# docker publish image tasks
# .PHONY: publish_dev
# publish_dev: build_dev
# 	@ echo "Publishing image to dev registry"
# 	@ docker push ${STG_IMG}
# 	@ echo "Done publishing: ${STG_IMG}"

.PHONY: publish_stg
publish_stg:
	@ echo "Promoting dev image to stg registry"
	# @ gcloud container images add-tag ${DEV_IMG} ${STG_IMG}  --quiet
	@ echo "Done promoting: to: ${STG_IMG}"

.PHONY: publish_preprod
publish_preprod:
	@ echo "Promoting stg image to preprod registry"
	@ gcloud container images add-tag ${STG_IMG} ${PREPROD_IMG}  --quiet
	# this helps during prd promotion to tag latest stg image
	@ gcloud container images add-tag ${STG_IMG} ${LATEST_PREPROD_IMG}  --quiet
	@ echo "Done promoting: ${STG_IMG} to: ${PREPROD_IMG} and ${LATEST_PREPROD_IMG}"

# since production publish is initiated via tags, at that moment it overrides
# the tag that was used in stg and dev, obtained via git describe. hence it has
# to be fetched from registry and used from there.
.PHONY: publish_prd
publish_prd:
	@ echo "Promoting latest stg image to prd registry with final tag: ${PRD_TAG}"
	@ gcloud container images add-tag ${LATEST_PREPROD_IMG} ${PRD_IMG}  --quiet
	@ echo "Done promoting: ${LATEST_PREPROD_IMG} to: ${PRD_IMG}"
# end - docker publish image tasks

# should only be invoked by ci-cd pipeline
.PHONY: configure
configure:
	@ gcloud auth activate-service-account --key-file ${GCLOUD_SA_KEY}
	@ gcloud auth configure-docker --quiet
	@ gcloud container clusters get-credentials ${cluster} ${location} --project ${project}
	@ kubectl config set-context --current --namespace=${NAMESPACE}
# end - configuration tasks

# k8s deployment tasks
.PHONY: install
install:
	@ echo "Deploying image: ${IMG} into ${env} cluster"
	@ cd deployment/overrides/${env} && \
		kustomize edit set image IMAGE_PLACEHOLDER=${IMG} && \
		kustomize build ./  | \
		sed 's|VERSION|${VERSION}|g' | \
		kubectl apply -f -

.PHONY: install_dev
install_dev:
	@ $(MAKE) install env=dev IMG=${DEV_IMG} VERSION=${DEV_TAG}

.PHONY: install_stg
install_stg:
	@ $(MAKE) install env=stg IMG=${STG_IMG} VERSION=${STG_TAG}

.PHONY: install_preprod
install_preprod:
	@ $(MAKE) install env=preprod IMG=${PREPROD_IMG} VERSION=${PREPROD_TAG}

.PHONY: install_prd
install_prd:
	@ $(MAKE) install env=prd IMG=${PRD_IMG} VERSION=${PRD_TAG}
# end k8s deployment tasks
