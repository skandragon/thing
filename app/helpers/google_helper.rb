# encoding: utf-8

module GoogleHelper
  def google_analytics
    account_code = APP_CONFIG[:google_analytics_id] # Set to UA-XXX-X
    if Rails.env == 'production' and account_code.present?
      ret = <<END_OF_CODE
<script type="text/javascript">
var _gaq = _gaq || [];
_gaq.push(['_setAccount', '#{account_code}']);
_gaq.push(['_trackPageview']);
(function() {
var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();

window.trackEvent = function(category, action) {
  _gaq.push(['_trackEvent', category, action]);
};
</script>
END_OF_CODE
    else
      ret = <<END_OF_CODE
<script type="text/javascript">
window.trackEvent = function(category, action) {};
</script>
END_OF_CODE
    end
    ret.html_safe
  end
end
