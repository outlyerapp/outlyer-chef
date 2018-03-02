cp .kitchen.yml .kitchen.local.yml
sed -i "s/XXX-XXX-XXX-XXX-XXX/$AGENT_KEY/" .kitchen.local.yml

cp data/integration_test.yml.template test/integration/default/integration_test.yml
sed -i "s/XXX.XXX.XXX-XXX-XXX/$AUTH_TOKEN/" test/integration/default/integration_test.yml
