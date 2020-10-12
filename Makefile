.PHONY: update_dummy_with_vendor
update_dummy_with_vendor:
	cd test/dummy_with_vendor/ && go get -u github.com/aws/aws-sdk-go

.PHONY: update_dummy_without_vendor
update_dummy_without_vendor:
	cd test/dummy_without_vendor/ && go get -u github.com/aws/aws-sdk-go

.PHONY: update_dummy_all
update_dummy_all: update_dummy_with_vendor update_dummy_without_vendor
