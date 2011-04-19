
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  
<meta http-equiv="X-UA-Compatible" content="chrome=1">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>plugins/software/test/functional/patches_controller_test.rb - yast-web-client in openSUSE - Gitorious</title>
<link href="/stylesheets/all.css?1303197994" media="screen" rel="stylesheet" type="text/css" />
<script src="/javascripts/all.js?1303197994" type="text/javascript"></script>      <link href="/stylesheets/prettify/prettify.css?1303197994" media="screen" rel="stylesheet" type="text/css" />    <script src="/javascripts/lib/prettify.js?1303197994" type="text/javascript"></script>        <script type="text/javascript" charset="utf-8">
      $(document).ready(function(){
          if ($("#codeblob tr td.line-numbers:last").text().length < 3500) {
              prettyPrint();
          } else {
              $("#long-file").show().find("a#highlight-anyway").click(function(e){
                  prettyPrint();
                  e.preventDefault();
              });
          }
      });
    </script>
  <!--[if IE 8]>
<link rel="stylesheet" href="/stylesheets/ie8.css" type="text/css">
<![endif]-->
<!--[if IE 7]>
<link rel="stylesheet" href="/stylesheets/ie7.css" type="text/css">
<![endif]-->

<script type="text/javascript">
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-52238-3']);
_gaq.push(['_setDomainName', '.gitorious.org'])
_gaq.push(['_trackPageview']);
(function() {
   var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
   ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
   (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);
})();
</script>
</head>

<body id="blobs">
<div id="wrapper">
    <ul id="user-nav">
	<li><a href="/">Dashboard</a></li>
	
    <li class="secondary"><a href="/~schubi">~schubi</a></li>
  <li class="secondary messages unread">
          <a href="/messages">1</a>      </li>
  <li class="secondary subtle"><a href="/logout">Logout</a></li>
  </ul>
  <div id="header">
    <h1 id="logo">
      <a href="/"><img alt="Logo" src="/img/logo.png?1294322727" /></a>    </h1>

    <ul id="menu">
              <li>
          <a href="/activities">Activities</a>
        </li>
                    <li class="activity"><a href="/activities">Activities</a></li>
        <li class="projects"><a href="/projects">Projects</a></li>
        <li class="teams"><a href="/teams">Teams</a></li>
          </ul>

  </div>
  
	<div id="top-bar">
    <ul id="breadcrumbs">
      <li class="project"><a href="/opensuse">openSUSE</a></li><li class="repository"><a href="/opensuse/yast-web-client">yast-web-client</a></li><li class="branch"><a href="/opensuse/yast-web-client/commits/maintenance-webyast-1.1">maintenance-webyast-1.1</a></li><li class="tree"><a href="/opensuse/yast-web-client/trees/maintenance-webyast-1.1">/</a></li><li class="folder"><a href="/opensuse/yast-web-client/trees/maintenance-webyast-1.1/plugins">plugins</a></li><li class="folder"><a href="/opensuse/yast-web-client/trees/maintenance-webyast-1.1/plugins/software">software</a></li><li class="folder"><a href="/opensuse/yast-web-client/trees/maintenance-webyast-1.1/plugins/software/test">test</a></li><li class="folder"><a href="/opensuse/yast-web-client/trees/maintenance-webyast-1.1/plugins/software/test/functional">functional</a></li><li class="file"><a href="/opensuse/yast-web-client/blobs/maintenance-webyast-1.1/plugins/software/test/functional/patches_controller_test.rb">patches_controller_test.rb</a></li>    </ul>
          <div id="searchbox">
        


<div class="search_bar">
<form action="http://gitorious.org/search" method="get"><p>
  <input class="text search-field round-5" id="q" name="q" type="text" /> 
  <input type="submit" value="Search" class="search-submit round-5" />
</p>  
<p class="hint search-hint" style="display: none;">
  eg. 'wrapper', 'category:python' or '"document database"'
  </p>
</form></div>
      </div>
      </div>

  <div id="container" class="">
    <div id="content" class="">
      
      



<div class="page-meta">
  <ul class="page-actions">
    <li>Blob contents</li>
    <li><a href="/opensuse/yast-web-client/blobs/history/maintenance-webyast-1.1/plugins/software/test/functional/patches_controller_test.rb">Blob history</a></li>
    <li><a href="/opensuse/yast-web-client/blobs/raw/maintenance-webyast-1.1/plugins/software/test/functional/patches_controller_test.rb">Raw blob data</a></li>
  </ul>
</div>


<!-- mime: application/ruby -->

       <div id="long-file" style="display:none"
                  class="help-box center error round-5">
               <div class="icon error"></div>        <p>
          This file looks large and may slow your browser down if we attempt
          to syntax highlight it, so we are showing it without any
          pretty colors.
          <a href="#highlight-anyway" id="highlight-anyway">Highlight
          it anyway</a>.
        </p>
     </div>    <table id="codeblob" class="highlighted lang-rb">
<tr id="line1">
<td class="line-numbers"><a href="#line1" name="line1">1</a></td>
<td class="code"><pre class="prettyprint lang-rb">#--</pre></td>
</tr>
<tr id="line2">
<td class="line-numbers"><a href="#line2" name="line2">2</a></td>
<td class="code"><pre class="prettyprint lang-rb"># Copyright (c) 2011 Novell, Inc.</pre></td>
</tr>
<tr id="line3">
<td class="line-numbers"><a href="#line3" name="line3">3</a></td>
<td class="code"><pre class="prettyprint lang-rb"># </pre></td>
</tr>
<tr id="line4">
<td class="line-numbers"><a href="#line4" name="line4">4</a></td>
<td class="code"><pre class="prettyprint lang-rb"># All Rights Reserved.</pre></td>
</tr>
<tr id="line5">
<td class="line-numbers"><a href="#line5" name="line5">5</a></td>
<td class="code"><pre class="prettyprint lang-rb"># </pre></td>
</tr>
<tr id="line6">
<td class="line-numbers"><a href="#line6" name="line6">6</a></td>
<td class="code"><pre class="prettyprint lang-rb"># This program is free software; you can redistribute it and/or modify it</pre></td>
</tr>
<tr id="line7">
<td class="line-numbers"><a href="#line7" name="line7">7</a></td>
<td class="code"><pre class="prettyprint lang-rb"># under the terms of version 2 of the GNU General Public License</pre></td>
</tr>
<tr id="line8">
<td class="line-numbers"><a href="#line8" name="line8">8</a></td>
<td class="code"><pre class="prettyprint lang-rb"># as published by the Free Software Foundation.</pre></td>
</tr>
<tr id="line9">
<td class="line-numbers"><a href="#line9" name="line9">9</a></td>
<td class="code"><pre class="prettyprint lang-rb"># </pre></td>
</tr>
<tr id="line10">
<td class="line-numbers"><a href="#line10" name="line10">10</a></td>
<td class="code"><pre class="prettyprint lang-rb"># This program is distributed in the hope that it will be useful,</pre></td>
</tr>
<tr id="line11">
<td class="line-numbers"><a href="#line11" name="line11">11</a></td>
<td class="code"><pre class="prettyprint lang-rb"># but WITHOUT ANY WARRANTY; without even the implied warranty of</pre></td>
</tr>
<tr id="line12">
<td class="line-numbers"><a href="#line12" name="line12">12</a></td>
<td class="code"><pre class="prettyprint lang-rb"># MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the</pre></td>
</tr>
<tr id="line13">
<td class="line-numbers"><a href="#line13" name="line13">13</a></td>
<td class="code"><pre class="prettyprint lang-rb"># GNU General Public License for more details.</pre></td>
</tr>
<tr id="line14">
<td class="line-numbers"><a href="#line14" name="line14">14</a></td>
<td class="code"><pre class="prettyprint lang-rb"># </pre></td>
</tr>
<tr id="line15">
<td class="line-numbers"><a href="#line15" name="line15">15</a></td>
<td class="code"><pre class="prettyprint lang-rb"># You should have received a copy of the GNU General Public License</pre></td>
</tr>
<tr id="line16">
<td class="line-numbers"><a href="#line16" name="line16">16</a></td>
<td class="code"><pre class="prettyprint lang-rb"># along with this program; if not, contact Novell, Inc.</pre></td>
</tr>
<tr id="line17">
<td class="line-numbers"><a href="#line17" name="line17">17</a></td>
<td class="code"><pre class="prettyprint lang-rb"># </pre></td>
</tr>
<tr id="line18">
<td class="line-numbers"><a href="#line18" name="line18">18</a></td>
<td class="code"><pre class="prettyprint lang-rb"># To contact Novell about this file by physical or electronic mail,</pre></td>
</tr>
<tr id="line19">
<td class="line-numbers"><a href="#line19" name="line19">19</a></td>
<td class="code"><pre class="prettyprint lang-rb"># you may find current contact information at www.novell.com</pre></td>
</tr>
<tr id="line20">
<td class="line-numbers"><a href="#line20" name="line20">20</a></td>
<td class="code"><pre class="prettyprint lang-rb">#++</pre></td>
</tr>
<tr id="line21">
<td class="line-numbers"><a href="#line21" name="line21">21</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line22">
<td class="line-numbers"><a href="#line22" name="line22">22</a></td>
<td class="code"><pre class="prettyprint lang-rb">require File.join(File.dirname(__FILE__),'..','test_helper')</pre></td>
</tr>
<tr id="line23">
<td class="line-numbers"><a href="#line23" name="line23">23</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line24">
<td class="line-numbers"><a href="#line24" name="line24">24</a></td>
<td class="code"><pre class="prettyprint lang-rb">class PatchUpdatesControllerTest &lt; ActionController::TestCase</pre></td>
</tr>
<tr id="line25">
<td class="line-numbers"><a href="#line25" name="line25">25</a></td>
<td class="code"><pre class="prettyprint lang-rb">  # return contents of a fixture file +file+</pre></td>
</tr>
<tr id="line26">
<td class="line-numbers"><a href="#line26" name="line26">26</a></td>
<td class="code"><pre class="prettyprint lang-rb">  def fixture(file)</pre></td>
</tr>
<tr id="line27">
<td class="line-numbers"><a href="#line27" name="line27">27</a></td>
<td class="code"><pre class="prettyprint lang-rb">    IO.read(File.join(File.dirname(__FILE__), &quot;..&quot;, &quot;fixtures&quot;, file))</pre></td>
</tr>
<tr id="line28">
<td class="line-numbers"><a href="#line28" name="line28">28</a></td>
<td class="code"><pre class="prettyprint lang-rb">  end</pre></td>
</tr>
<tr id="line29">
<td class="line-numbers"><a href="#line29" name="line29">29</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line30">
<td class="line-numbers"><a href="#line30" name="line30">30</a></td>
<td class="code"><pre class="prettyprint lang-rb">  def setup</pre></td>
</tr>
<tr id="line31">
<td class="line-numbers"><a href="#line31" name="line31">31</a></td>
<td class="code"><pre class="prettyprint lang-rb">    # disable authentication</pre></td>
</tr>
<tr id="line32">
<td class="line-numbers"><a href="#line32" name="line32">32</a></td>
<td class="code"><pre class="prettyprint lang-rb">    PatchUpdatesController.any_instance.stubs(:login_required)</pre></td>
</tr>
<tr id="line33">
<td class="line-numbers"><a href="#line33" name="line33">33</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line34">
<td class="line-numbers"><a href="#line34" name="line34">34</a></td>
<td class="code"><pre class="prettyprint lang-rb">    # stub what the REST is supposed to return</pre></td>
</tr>
<tr id="line35">
<td class="line-numbers"><a href="#line35" name="line35">35</a></td>
<td class="code"><pre class="prettyprint lang-rb">    ActiveResource::HttpMock.set_authentication</pre></td>
</tr>
<tr id="line36">
<td class="line-numbers"><a href="#line36" name="line36">36</a></td>
<td class="code"><pre class="prettyprint lang-rb">    @header = ActiveResource::HttpMock.authentication_header</pre></td>
</tr>
<tr id="line37">
<td class="line-numbers"><a href="#line37" name="line37">37</a></td>
<td class="code"><pre class="prettyprint lang-rb">    ActiveResource::HttpMock.respond_to do |mock|</pre></td>
</tr>
<tr id="line38">
<td class="line-numbers"><a href="#line38" name="line38">38</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.resources({:&quot;org.opensuse.yast.system.patches&quot; =&gt; &quot;/patches&quot;},</pre></td>
</tr>
<tr id="line39">
<td class="line-numbers"><a href="#line39" name="line39">39</a></td>
<td class="code"><pre class="prettyprint lang-rb">          { :policy =&gt; &quot;org.opensuse.yast.system.patches&quot;})</pre></td>
</tr>
<tr id="line40">
<td class="line-numbers"><a href="#line40" name="line40">40</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.permissions &quot;org.opensuse.yast.system.patches&quot;, { :read =&gt; true, :write =&gt; true }</pre></td>
</tr>
<tr id="line41">
<td class="line-numbers"><a href="#line41" name="line41">41</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line42">
<td class="line-numbers"><a href="#line42" name="line42">42</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.get &quot;/patches.xml&quot;, @header, fixture(&quot;patches.xml&quot;), 200</pre></td>
</tr>
<tr id="line43">
<td class="line-numbers"><a href="#line43" name="line43">43</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.get &quot;/patches.xml?messages=true&quot;, @header, fixture(&quot;empty_messages.xml&quot;), 200</pre></td>
</tr>
<tr id="line44">
<td class="line-numbers"><a href="#line44" name="line44">44</a></td>
<td class="code"><pre class="prettyprint lang-rb">    end</pre></td>
</tr>
<tr id="line45">
<td class="line-numbers"><a href="#line45" name="line45">45</a></td>
<td class="code"><pre class="prettyprint lang-rb">  end</pre></td>
</tr>
<tr id="line46">
<td class="line-numbers"><a href="#line46" name="line46">46</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line47">
<td class="line-numbers"><a href="#line47" name="line47">47</a></td>
<td class="code"><pre class="prettyprint lang-rb">  def test_update_license_require</pre></td>
</tr>
<tr id="line48">
<td class="line-numbers"><a href="#line48" name="line48">48</a></td>
<td class="code"><pre class="prettyprint lang-rb">    ActiveResource::HttpMock.respond_to do |mock|</pre></td>
</tr>
<tr id="line49">
<td class="line-numbers"><a href="#line49" name="line49">49</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.resources({:&quot;org.opensuse.yast.system.patches&quot; =&gt; &quot;/patches&quot;},</pre></td>
</tr>
<tr id="line50">
<td class="line-numbers"><a href="#line50" name="line50">50</a></td>
<td class="code"><pre class="prettyprint lang-rb">          { :policy =&gt; &quot;org.opensuse.yast.system.patches&quot;})</pre></td>
</tr>
<tr id="line51">
<td class="line-numbers"><a href="#line51" name="line51">51</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.permissions &quot;org.opensuse.yast.system.patches&quot;, { :read =&gt; true, :write =&gt; true }</pre></td>
</tr>
<tr id="line52">
<td class="line-numbers"><a href="#line52" name="line52">52</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line53">
<td class="line-numbers"><a href="#line53" name="line53">53</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.get &quot;/patches.xml&quot;, @header, fixture(&quot;error_license_confirmation.xml&quot;), 503</pre></td>
</tr>
<tr id="line54">
<td class="line-numbers"><a href="#line54" name="line54">54</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.get &quot;/patches.xml?messages=true&quot;, @header, fixture(&quot;empty_messages.xml&quot;), 200</pre></td>
</tr>
<tr id="line55">
<td class="line-numbers"><a href="#line55" name="line55">55</a></td>
<td class="code"><pre class="prettyprint lang-rb">    end</pre></td>
</tr>
<tr id="line56">
<td class="line-numbers"><a href="#line56" name="line56">56</a></td>
<td class="code"><pre class="prettyprint lang-rb">    get :index</pre></td>
</tr>
<tr id="line57">
<td class="line-numbers"><a href="#line57" name="line57">57</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line58">
<td class="line-numbers"><a href="#line58" name="line58">58</a></td>
<td class="code"><pre class="prettyprint lang-rb">    assert_redirected_to :action =&gt; &quot;license&quot;</pre></td>
</tr>
<tr id="line59">
<td class="line-numbers"><a href="#line59" name="line59">59</a></td>
<td class="code"><pre class="prettyprint lang-rb">  end</pre></td>
</tr>
<tr id="line60">
<td class="line-numbers"><a href="#line60" name="line60">60</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line61">
<td class="line-numbers"><a href="#line61" name="line61">61</a></td>
<td class="code"><pre class="prettyprint lang-rb">  def test_show_license</pre></td>
</tr>
<tr id="line62">
<td class="line-numbers"><a href="#line62" name="line62">62</a></td>
<td class="code"><pre class="prettyprint lang-rb">    ActiveResource::HttpMock.respond_to do |mock|</pre></td>
</tr>
<tr id="line63">
<td class="line-numbers"><a href="#line63" name="line63">63</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.resources({:&quot;org.opensuse.yast.system.patches&quot; =&gt; &quot;/patches&quot;},</pre></td>
</tr>
<tr id="line64">
<td class="line-numbers"><a href="#line64" name="line64">64</a></td>
<td class="code"><pre class="prettyprint lang-rb">          { :policy =&gt; &quot;org.opensuse.yast.system.patches&quot;})</pre></td>
</tr>
<tr id="line65">
<td class="line-numbers"><a href="#line65" name="line65">65</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.permissions &quot;org.opensuse.yast.system.patches&quot;, { :read =&gt; true, :write =&gt; true }</pre></td>
</tr>
<tr id="line66">
<td class="line-numbers"><a href="#line66" name="line66">66</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line67">
<td class="line-numbers"><a href="#line67" name="line67">67</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.get &quot;/patches.xml&quot;, @header, fixture(&quot;patches.xml&quot;), 200</pre></td>
</tr>
<tr id="line68">
<td class="line-numbers"><a href="#line68" name="line68">68</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.get &quot;/patches.xml?messages=true&quot;, @header, fixture(&quot;empty_messages.xml&quot;), 200</pre></td>
</tr>
<tr id="line69">
<td class="line-numbers"><a href="#line69" name="line69">69</a></td>
<td class="code"><pre class="prettyprint lang-rb">      mock.get &quot;/patches.xml?license=1&quot;, @header, fixture(&quot;license.xml&quot;), 200</pre></td>
</tr>
<tr id="line70">
<td class="line-numbers"><a href="#line70" name="line70">70</a></td>
<td class="code"><pre class="prettyprint lang-rb">    end</pre></td>
</tr>
<tr id="line71">
<td class="line-numbers"><a href="#line71" name="line71">71</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line72">
<td class="line-numbers"><a href="#line72" name="line72">72</a></td>
<td class="code"><pre class="prettyprint lang-rb">    get :license</pre></td>
</tr>
<tr id="line73">
<td class="line-numbers"><a href="#line73" name="line73">73</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line74">
<td class="line-numbers"><a href="#line74" name="line74">74</a></td>
<td class="code"><pre class="prettyprint lang-rb">    assert_response :success</pre></td>
</tr>
<tr id="line75">
<td class="line-numbers"><a href="#line75" name="line75">75</a></td>
<td class="code"><pre class="prettyprint lang-rb">  end</pre></td>
</tr>
<tr id="line76">
<td class="line-numbers"><a href="#line76" name="line76">76</a></td>
<td class="code"><pre class="prettyprint lang-rb"></pre></td>
</tr>
<tr id="line77">
<td class="line-numbers"><a href="#line77" name="line77">77</a></td>
<td class="code"><pre class="prettyprint lang-rb">end</pre></td>
</tr>
</table>  
    </div>
      </div>
	<div id="footer">
      
<div class="powered-by">
	<a href="http://www.shortcut.no"><img alt="Shortcut" src="/images/../img/shortcut.png?1294322727" title="A product from Shortcut" /></a>  	<a href="http://gitorious.org"><img alt="Poweredby" src="/images/../img/poweredby.png?1294322727" title="Powered by Gitorious" /></a></div>
<script type="text/javascript">
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-52238-3']);
_gaq.push(['_setDomainName', '.gitorious.org'])
_gaq.push(['_trackPageview']);
(function() {
   var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
   ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
   (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);
})();
</script><script type="text/javascript" src="/javascripts/onload.js"></script>
	<div id="footer-links">
		<h3>Gitorious</h3>
		<ul>
			<li><a href="/">Home</a></li>
	        <li><a href="/about">About Gitorious</a></li>
	        <li><a href="/about/faq">FAQ</a></li>
	        <li><a href="/contact">Contact</a></li>
		</ul>
		<ul>
			<li><a href="http://groups.google.com/group/gitorious">Discussion group</a></li>
	        <li><a href="http://blog.gitorious.org">Blog</a></li>
		</ul>
				<ul>
			<li><a href="http://en.gitorious.org/tos">Terms of Service</a></li>
          	<li><a href="http://en.gitorious.org/privacy_policy">Privacy Policy</a></li>
		</ul>
		
	</div>

      <div class="clear"></div>
    </div>
</div>
</body>
</html>
