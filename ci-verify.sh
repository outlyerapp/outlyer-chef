cp test/integration/default/integration_test.yml.example test/integration/default/integration_test.yml
sed -i "s/XXX.XXX.XXX-XXX-XXX/$AUTH_TOKEN/" test/integration/default/integration_test.yml

kitchen verify $BOX
