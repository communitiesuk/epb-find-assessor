ALL_SCOPES = %w[scheme:assessor:list scheme:list].freeze

def check_response(response, accepted_responses)
  if accepted_responses.include?(response.status)
    response
  else
    raise UnexpectedApiError.new(
      {
        expected_status: accepted_responses,
        actual_status: response.status,
        response_body: response.body,
      },
    )
  end
end

def assertive_request(
  request, accepted_responses, authenticate, auth_data, scopes = []
)
  response =
    if authenticate
      if auth_data
        authenticate_with_data(auth_data, scopes) { request.call }
      else
        authenticate_with_data({}, scopes) { request.call }
      end
    else
      request.call
    end
  check_response(response, accepted_responses)
end

def assertive_put(
  path, body, accepted_responses, authenticate, auth_data, scopes
)
  assertive_request(
    -> { put(path, body.to_json) },
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def assertive_get(path, accepted_responses, authenticate, auth_data, scopes)
  assertive_request(
    -> { get(path) },
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def assertive_post(
  path, body, accepted_responses, authenticate, auth_data, scopes, json = true
)
  body = body.to_json if json
  assertive_request(
    -> { post(path, body) },
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def fetch_assessors(
  scheme_id,
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil,
  scopes = %w[scheme:assessor:list]
)
  assertive_get(
    "/api/schemes/#{scheme_id}/assessors",
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def fetch_assessor(
  scheme_id,
  assessor_id,
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil,
  scopes = %w[scheme:assessor:fetch]
)
  auth_data ||= { 'scheme_ids': [scheme_id] }
  assertive_get(
    "/api/schemes/#{scheme_id}/assessors/#{assessor_id}",
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def add_assessor(
  scheme_id,
  assessor_id,
  body,
  accepted_responses = [200, 201],
  authenticate = true,
  auth_data = nil,
  scopes = %w[scheme:assessor:update]
)
  auth_data ||= { 'scheme_ids': [scheme_id] }
  assertive_put(
    "/api/schemes/#{scheme_id}/assessors/#{assessor_id}",
    body,
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def add_scheme(
  name = "test scheme",
  accepted_responses = [201],
  authenticate = true,
  auth_data = nil,
  scopes = %w[scheme:create]
)
  assertive_post(
    "/api/schemes",
    { name: name },
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def lodge_assessment(
  assessment_body: "",
  accepted_responses: [201],
  authenticate: true,
  auth_data: nil,
  scopes: %w[assessment:lodge],
  json: false,
  schema_name: "RdSAP-Schema-19.0"
)
  header "Content-type", "application/xml+" + schema_name
  assertive_post(
    "api/assessments",
    assessment_body,
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
    json,
  )
end

def add_scheme_and_get_id(
  name = "test scheme", accepted_responses = [201], authenticate = true
)
  JSON.parse(add_scheme(name, accepted_responses, authenticate).body)["data"][
    "schemeId"
  ]
end

def add_scheme_then_assessor(body, accepted_responses = [200, 201])
  scheme_id = add_scheme_and_get_id
  response = add_assessor(scheme_id, "TEST_ASSESSOR", body, accepted_responses)
  response
end

def fetch_assessment(
  assessment_id,
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil,
  scopes = %w[assessment:fetch]
)
  assertive_get(
    "api/assessments/#{assessment_id}",
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def migrate_assessment(
  assessment_id,
  assessment_body,
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil,
  scopes = %w[migrate:assessment]
)
  assertive_put(
    "api/assessments/#{assessment_id}",
    assessment_body,
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def domestic_assessments_search_by_postcode(
  postcode,
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil,
  scopes = %w[assessment:search]
)
  assertive_get(
    "/api/assessments/search?postcode=#{postcode}",
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def domestic_assessments_search_by_assessment_id(
  assessment_id,
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil,
  scopes = %w[assessment:search]
)
  assertive_get(
    "/api/assessments/search?assessment_id=#{assessment_id}",
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def domestic_assessments_search_by_street_name_and_town(
  street_name,
  town,
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil,
  scopes = %w[assessment:search]
)
  assertive_get(
    "/api/assessments/search?street_name=#{street_name}&town=#{town}",
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def assessors_search(
  postcode,
  qualification,
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil,
  scopes = %w[assessor:search]
)
  assertive_get(
    "/api/assessors?postcode=#{postcode}&qualification=#{qualification}",
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def assessors_search_by_name(
  name,
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil,
  scopes = %w[assessor:search]
)
  assertive_get(
    "/api/assessors?name=#{name}",
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end

def schemes_list(
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil,
  scopes = %w[scheme:list]
)
  assertive_get(
    "/api/schemes",
    accepted_responses,
    authenticate,
    auth_data,
    scopes,
  )
end
