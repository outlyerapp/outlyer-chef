sed "s/XXX-XXX-XXX-XXX-XXX/$AGENT_KEY/;s/version: nil/version: $VERSION/;s/package_distribution: stable/package_distribution: $PACKAGE_DISTRIBUTION/" .kitchen.yml > .kitchen.local.yml

sed "s/XXX.XXX.XXX-XXX-XXX/$AUTH_TOKEN/" data/integration_test.yml.template > test/integration_test.yml
