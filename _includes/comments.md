{% if page.thread %}
	<div id="cloud-tie-wrapper" class="cloud-tie-wrapper"></div>
	<script src="https://img1.cache.netease.com/f2e/tie/yun/sdk/loader.js"></script>
	<script>
	var cloudTieConfig = {
	  url: document.location.href, 
	  sourceId: "",
	  productKey: "de26135a73da44f0954e924fc7cfdba8",
	  target: "cloud-tie-wrapper"
	};
	var yunManualLoad = true;
	Tie.loader("aHR0cHM6Ly9hcGkuZ2VudGllLjE2My5jb20vcGMvbGl2ZXNjcmlwdC5odG1s", true);
	</script>
{% endif %}