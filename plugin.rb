# name: discourse-weasyl-onebox-plugin
# about: Adds support for properly embedding Weasyl submissions as OneBox items in Discourse
# version: 1.0
# authors: Anton Struyk
# url: https://github.com/astruyk/discourse-weasyl-onebox-plugin

require 'multi_json'

class Onebox::Engine::WeasylSubmissionOnebox
	include Onebox::Engine

	# Example submission URL is https://www.weasyl.com/~pandapaco/submissions/1616105/ball-of-yarn
	REGEX = /^https?:\/\/(?:www\.)?weasyl\.com\/~[0-9a-zA-z\-_]*?\/submissions\/(?<id>[0-9]+)\/(?:.)*$/
	matches_regexp REGEX

	def to_html
		linkUrl = @url;
		title = "Weasyl Submission";
		description = "";
		imageUrl = "https://cdn.weasyl.com/static/images/logo.png";
		iconUrl = "https://cdn.weasyl.com/static/images/favicon.png";
		error_message = "";

		# Weasyl exposes an HTTP API, so we can get JSON objects directly from it.
		submissionId = @url.match(REGEX)[:id];
		api_submissionUrl = "https://www.weasyl.com/api/submissions/#{submissionId}/view";
		title = api_submissionUrl;
		begin
			jsonResponse = Onebox::Helpers::fetch_response(api_submissionUrl);
			result = ::MultiJson.load(jsonResponse);
			description = result.try(:[], "description") || description;
			title = result.try(:[], "title") || title;
			if !result.try(:[], "media").try(:[], "thumbnail").nil?
				imageUrl = result.try(:[], "media").try(:[], "thumbnail")[0].try(:[], "url") || imageUrl;
			end
		rescue StandardError => err
			title = "NSFW Submission";
			description = "This submission information is hidden. Likely because it is marked as NSFW.";
			error_message = "#{err.class} - #{err.message} \n\n #{err.backtrace.join('\n')}";
		end

		<<-HTML
				<aside class="onebox whitelistedgeneric">
					<header class="source">
						<img src="#{iconUrl}" class="site-icon" style="width: 16px; height: 16px" >
						<a href="#{linkUrl}" target="_blank" rel="nofollow noopener">weasyl.com</a>
					</header>
					<article class="onebox-body">
						<img src="#{imageUrl}" class="thumbnail size-resolved" />
						<h3><a href="#{linkUrl}" target="_blank" rel="nofollow noopener">#{title}</a></h3>
						<p>#{description}</p>
						<pre hidden>#{error_message}</pre>
						<div style="clear: both"></div>
					</article>
				</aside>
			HTML
	end
end