<?php
// Get POST variables from webhook
if(isset($_POST['token'])){ $params = 'token=' . $_POST['token']; }
if(isset($_POST['param1'])){ $params = $params . '&param1' . $_POST['param1']; }
if(isset($_POST['param2'])){ $params = $params . '&param2=' . $_POST['param2']; }

// Set variables
$jenkins_url = 'http://jenkins.domain.org/job/';
$jenkins_job_name = 'name-of-your-jenkins-job-to-trigger';

// Check if at least the token is given
if(isset($_POST['token']) ){
	// Get cURL resource
	$curl = curl_init();
	// Set some options - we are passing in a useragent too here
	curl_setopt_array($curl, array(
		CURLOPT_RETURNTRANSFER => 1,
		CURLOPT_URL => "$jenkins_url$jenkins_job_name/buildWithParameters?$params",
		CURLOPT_USERAGENT => 'Github webhook'
	));

	// Send the request & save response to $resp
	$resp = curl_exec($curl);

	// Close request to clear up some resources
	curl_close($curl);
}
