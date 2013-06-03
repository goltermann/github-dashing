# Github Contribution Dashboard

Dashboard to monitor the health of github projects based on their contribution statistics.

 - Uses data gathered by [githubarchive.org](http://githubarchive.org), and views the
data through [Dashing](http://shopify.github.com/dashing), a Ruby web application
built on the [Sinatra](http://www.sinatrarb.com) framework.
 - Widgets support aggregate statistics of multiple repos or even all repos within an organization.
 - Easy hosting through [Heroku](http://heroku.com)

![Preview](assets/images/preview.png?raw=true)

## Setup

### Configuration

First install the required dependencies through `bundle install`.

The project is configured through environment variables.
Copy the `.env.sample` configuration file to `.env`.

 * `ORGAS`: Organizations (required). Separate multiple by comma. Will use all repos unless filtered in REPOS. 
   Example: `silverstripe,silverstripe-labs`
 * `REPOS`: # Repositories (optional). Separate multiple by comma. If used alongsize `ORGAS`, the logic will add
   all mentioned repos to the ones retrieves from `ORGAS`.
   Example: `silverstripe/silverstripe-framework,silverstripe/silverstripe-cms`
 * `SINCE`: Date string, or relative time parsed through [http://guides.rubyonrails.org/active_support_core_extensions.html](ActiveSupport). Example: `12.months.ago.beginning_of_month`, `2012-01-01`
 * `GITHUB_LOGIN`: Github authentication is optional, but recommended
 * `GITHUB_OAUTH_TOKEN`: See above
 * `LEADERBOARD_WEIGHTING`: Comma-separated weighting pairs influencing the multiplication of values
   used for the leaderboard widget score.
   Example: `issues_opened=5,issues_closed=5,pull_requests_opened=10,pull_requests_closed=5,pull_request_comments=1,issue_comments=1,commit_comments=1,commits=20`
 * `GOOGLE_KEY`: Converted P12 key downloaded from Google (see below for conversion instructions)
 * `GOOGLE_SECRET`: Secret from your [https://code.google.com/apis/console](Google API Console) (defaults to 'notasecret')
 * `GOOGLE_ISSUER`: "Email address" from your [https://code.google.com/apis/console](Google API Console)
 * `GOOGLE_PROJECT_ID`: "Product name" from your [https://code.google.com/apis/console](Google API Console)

### Bigquery API Access

The data is retrieved through Google's [BigQuery API](https://developers.google.com/bigquery/),
which requires OAuth2 authentication against your Google account.

 1. [Sign up](https://developers.google.com/bigquery/sign-up) for the service
 1. Go to the [Google APIs Console](https://code.google.com/apis/console) and open your 'API Project'.
 1. Click API Access.
 1. Click Create an OAuth 2.0 client ID.
 1. In the Product Name field enter "Github Dashboard" and click "next"
 1. Choose application type "Service account" and click "create"
 1. Download the private key, and store it in `privatekey.p12`
 1. Convert the private key through `openssl pkcs12 -in privatekey.p12 -nocerts -nodes`
 1. Insert the resulting key into `GOOGLE_KEY` and you `GOOGLE_SECRET` in `.env` (replacing all newlines with `\n`)
 1. Insert "Product name" (`GOOGLE_PROJECT_ID`) and "Client ID" (`GOOGLE_ISSUER`) values into `.env`

### Github API Access

The dashboard uses the public github API, which doesn't require authentication.
Depending on how many repositories you're showing, hundreds of API calls might be necessary,
which can quickly exhaust the API limitations for unauthenticated use.

In order to authenticate, create a new [API Access Token](https://github.com/settings/applications)
on your github.com account, and add it to the `.env` configuration:

	GITHUB_LOGIN=your_login
	GITHUB_OAUTH_TOKEN=2b0ff00...................

## Usage

Finally, start the dashboard server:

	dashing start

Now you can browse the dashboard at `http://localhost:3030/default`.

## Tasks and Data Usage

The Dashing jobs query for their data whenever the server is started, and then with a frequency of 1h by default. 
Keep in mind that Google's BigQuery API has limited free quotas ([details](https://cloud.google.com/pricing/big-query)),
after which every query gets charged against your Google account (since you have to provide payment details to use the service).
The githubarchive.org crawler also imports new data with a short [delay](https://github.com/igrigorik/githubarchive.org/blob/master/crawler/tasks.cron). Given these constraints, realtime statistics aren't feasible.

## Heroku Deployment

Since Dashing is simply a Sinatra Rack app under the hood, deploying is a breeze. 
It takes around 30 seconds to do :) 

First, [sign up](https://id.heroku.com/signup) for the free service.
[Download](https://devcenter.heroku.com/articles/quickstart) the dev tools
and install them with your account credentials.

Due to a bug in config pushing on Heroku, its important to leave all single-line values in `.env` unquoted.

Now you're ready to add your app to Heroku:

	# Create a git repo for your project, and add your files.
	git init
	git add .
	git commit -m "My beautiful dashboard"

	# Create the application on Heroku 
	heroku apps:create myapp

	# Push the application to Heroku
	git push heroku master

	# Push your `.env` configuration
	heroku plugins:install git://github.com/ddollar/heroku-config.git
	heroku config:push

Heroku mangles the `GOOGLE_KEY` newlines, so we need to push it separately without `\n` chars:

	heroku config:set GOOGLE_KEY="-----BEGIN PRIVATE KEY-----
	MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAKdV4u/5qVxi3tIZ
	...
	Hb4URYZSOiBB
	-----END PRIVATE KEY-----"

