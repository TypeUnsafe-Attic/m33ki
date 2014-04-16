function getScripts(){ return [
  "js/components/BigTitle.js",
  "js/main.js"
];};

getScripts().forEach(function(s){
	var script = document.createElement('script');
	script.src = s;
	script.type = "text/jsx";
	document.querySelector('head').appendChild(script);
});


