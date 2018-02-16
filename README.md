# Poster Boy

A command line tool allowing you to run API requests in bulk, using a request template and a CSV
of data to "mail merge" into the request template.

## Execution

```
  $ bin/poster_boy --template my-template.yml.erb --data my-data.csv --execute
```

... or just run `bin/poster_boy --help` for documentation.

Exclude the `--execute` argument to see the results of a dry run (just the details of the API
requests that *would* be run).

## Request templates

A [ERB](http://www.stuartellis.name/articles/erb/) of a [YAML](http://www.yaml.org/start.html) file
is used so that you can specifically which parts of your file should be filled in dynamically.

```yaml
method: POST
target_url: https://an.url
basic_authentication: # optional
  user_name: my_user_name
  password: my_password
headers: # optional
  name: <%= csv_row['user_name'] %>
parameters: # optional
  api_token: <%= prompt_for_secret_data 'Please enter the API token:' %>
  request_body: <%= csv_row['html_email_body'] %>
```

In the `basic_authentication` section, specify the user name and password you want to use for
basic authentication.

In the `headers` section, specify the name/value pairs you want to go into the request headers.

In the `parameters` section, specify the full parameter structure you want sent.

There are two options for substituting dynamic data into the request:

1. Use the `prompt_for_secret_data` method. This will prompt the user to type in the value at
   runtime. This is useful for secret things (like passwords or API tokens) that you don't want to
   leave lying around unencrypted on your file system. Each `prompt_for_secret_data` call you make
   is memoized using the prompt string, so you'll only be prompted once for each individual value.
2. Access the data from each row of the CSV file using the convention `csv_row['column_name']`.

## Data files

Use standard CSVs with named columns (the first row should just be the column names so you can
reference them in your template).
