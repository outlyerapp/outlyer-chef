sed "s/XXX-XXX-XXX-XXX-XXX/$AGENT_KEY/" .kitchen.yml > .kitchen.local.yml

sed "s/XXX.XXX.XXX-XXX-XXX/$AUTH_TOKEN/" data/integration_test.yml.template > test/integration_test.yml
