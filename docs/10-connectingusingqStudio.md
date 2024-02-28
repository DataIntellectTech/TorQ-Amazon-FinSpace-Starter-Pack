Connecting Using qStudio
===============

Open qStudio, right-click on Servers in the top left corner and select 'Add Server'.

![Add Server Connection](workshop/graphics/Servers_qStudio.png)

You will then see a pop-up showing the server properties. This is where you will add the information from the connection string.

![Server Properties](workshop/graphics/Server_Properties.png)

The generated connection string provides you with everything you need to fill this out, take this connection string for example;

![Connection String](workshop/graphics/ConnectionString.png)

The required fields in the Server Properties screen are contained within the connection string and are colon separated. Here,

``Host:`` vpce-0471a7041d652985f-0monuk67.vpce-svc-0793a6d47138b14fb.us-west-2.vpce.amazonaws.com

``Port:`` 443

``Name:`` This is just the name of your process, can be anything i.e. rdb

``Username:`` david-finspace

``Password:`` Host=vpce-0471a7041d652985f-0monuk67.vpce-svc-0793a6d47138b14fb.us-west-2.vpce.amazonaws.com&Port=443&User=david-finspace&Action=finspace%3AConnectKxCluster&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEAcaCXVzLXdlc3QtMiJGMEQCIGQd7tN%2FXAj8hGQg1sA2T1R2r5usyoP2qpMQedvA4evFAiBaz8Ce9LBhkWiYmIpNcwNCLfOupH57K82YWxVXdxvhQCqBAwjw%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAIaDDc2NjAxMjI4NjAwMyIMZBp6QRId8Dl3V42QKtUCkPWLvgV61rur1vHYnJKuZtMaS%2FBqSxoihJjsH8oEt7HOIjPh7jlehXOAvHHsmAV4gF9l49zFDd39L1VSjzM0R%2BN0LHyUSEya64%2BOIksQ4BAc2TmtxqDWNeDzpFQ7X8%2FWWVTrS5YFedH4iP4XtPoVf0KmQhVRepAbd91nFCJVEv8Wg66zKgg55onPs8B3hH%2FdWIwgrJIe2247VhKJHElLsY3Fi%2FcWR8P%2FMZB%2FcoziItOUfmTrmXg59qxKQWReGIONhbV1IFtEK2tDkaeaKgNiCEY1ZqdFcsxUlFWxWgy5%2FwUVQxEvRkUYdhRGTQm6zOXaKwL0Ut5WKdt%2FCiSvw4BUib7XCf10Y%2FwSbTHFfhFQ2YGgcR54a0WD1J3RN8D%2F%2BjDoD90kej4uled1I8N3bOX1Ppvy1x0oDVBI3H%2F%2BP5U3Vqh8pLTQ5i3euZtgGabuzLbw2WmAMPMwppH9rgY6wAFQ4SVgm%2F%2BdcaXt%2Fw7plQ1NHbKHPHaqQUedw%2BSmsSvYZ3ubyO0eg%2F%2FvDajhf49EOj4H1mQQrzqTl%2BGA10rhn8JMam0a1Bc8WvOl4deoW4pDFPL15By9cQ3FK30%2ByGn2U0STnHbMgaf4PgQ%2BIC0CiCNiTx7JxYUlVnBPCtmzC8rz0YZ24Px92yHtFj6VFmnyLT%2ByJQCSFc6lMtLzPWtfE1SHyexx%2BGb2a3r2tGDbm%2FcAsClZgktDwD7h4bCzSA7OjJ4%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20240228T145222Z&X-Amz-SignedHeaders=host&X-Amz-Expires=900&X-Amz-Credential=ASIA3EWPD4QZ2MMPTPVJ%2F20240228%2Fus-west-2%2Ffinspace-apricot%2Faws4_request&X-Amz-Signature=9473c826d24c7e8066b0e10debad8a2779b8ae596ffa7056d344f9548923a210

![All Servers](workshop/graphics/CompleteServers.png)
