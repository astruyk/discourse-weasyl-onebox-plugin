# name: discourse-weasyl-onebox-plugin
# about: Adds support for properly embedding Weasyl submissions as OneBox items in Discourse
# version: 1.0
# authors: Anton Struyk
# url: https://github.com/astruyk/discourse-weasyl-onebox-plugin

require "net/http"
require "uri"
require "json"

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

		begin
			# Weasyl exposes an HTTP API, so we can get JSON objects directly from it.
			submissionId = @url.match(REGEX)[:id];
			api_submissionUrl = "https://www.weasyl.com/api/submissions/#{submissionId}/view"
			title = api_submissionUrl;
			contents = open(api_submissionUrl).read;
			description = contents;
			# result = JSON.parse(contents);

			# description = result.dig('description');
			# title = result.dig('title');
			# imageUrl = result.dig('media', 'thumbnail_generated', 'url');

		rescue StandardError => err
			title = "Error";
			description = err.message + "\n\n" + err.backtrace;
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
					<div style="clear: both"></div>
				</article>
        	</aside>
        HTML
	end
end