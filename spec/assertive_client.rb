def check_response(response, accepted_responses)
  if accepted_responses.include?(response.status)
    response
  else
    raise UnexpectedApiError.new(
        {
            expected_status: accepted_responses,
            actual_status: response.status,
            response_body: response.body
        }
    )
  end
end

def assertive_request(request, accepted_responses, authenticate, auth_data)
  if authenticate
    if auth_data
      response = authenticate_with_data(auth_data) { request.call }
    else
      response = authenticate_and { request.call }
    end
  else
    response = request.call
  end
  check_response(response, accepted_responses)
end

def assertive_put(path, body, accepted_responses, authenticate, auth_data)
  assertive_request(
    -> { put(path, body.to_json) },
    accepted_responses,
    authenticate,
    auth_data
  )
end

def assertive_get(path, accepted_responses, authenticate, auth_data)
  assertive_request(-> { get(path) }, accepted_responses, authenticate, auth_data)
end

def assertive_post(path, body, accepted_responses, authenticate, auth_data)
  assertive_request(
    -> { post(path, body.to_json) },
    accepted_responses,
    authenticate,
    auth_data
  )
end

def fetch_assessors(scheme_id, accepted_responses = [200], authenticate = true, auth_data=nil)
  assertive_get("/api/schemes/#{scheme_id}/assessors", accepted_responses, authenticate, auth_data)
end

def fetch_assessor(
  scheme_id, assessor_id, accepted_responses = [200], authenticate = true, auth_data=nil
)
  assertive_get(
    "/api/schemes/#{scheme_id}/assessors/#{assessor_id}",
    accepted_responses,
    authenticate,
    auth_data
  )
end

def add_assessor(
  scheme_id,
  assessor_id,
  body,
  accepted_responses = [200, 201],
  authenticate = true,
  auth_data=nil
)
  assertive_put(
    "/api/schemes/#{scheme_id}/assessors/#{assessor_id}",
    body,
    accepted_responses,
    authenticate,
    auth_data
  )
end

def add_scheme(
  name = 'test scheme', accepted_responses = [201], authenticate = true, auth_data=nil
)
  assertive_post(
    '/api/schemes',
    { name: name },
    accepted_responses,
    authenticate,
    auth_data
  )
end

def add_scheme_and_get_name(
  name = 'test scheme', accepted_responses = [201], authenticate = true
)
  JSON.parse(add_scheme(name, accepted_responses, authenticate).body)['data'][
    'schemeId'
  ]
end

def add_scheme_then_assessor(body, accepted_responses = [200, 201])
  scheme_id = add_scheme_and_get_name
  response = add_assessor(scheme_id, 'TEST_ASSESSOR', body, accepted_responses)
  response
end

def fetch_assessment(
  assessment_id, accepted_responses = [200], authenticate = true, auth_data = nil
)
  assertive_get(
    "api/assessments/domestic-epc/#{assessment_id}",
    accepted_responses,
    authenticate,
    auth_data
  )
end

def migrate_assessment(
  assessment_id,
  assessment_body,
  accepted_responses = [200],
  authenticate = true,
  auth_data = nil
)
  assertive_put(
    "api/assessments/domestic-epc/#{assessment_id}",
    assessment_body,
    accepted_responses,
    authenticate,
    auth_data
  )
end

def assessments_search_by_postcode(
  postcode, accepted_responses = [200], authenticate = true, auth_data = nil
)
  assertive_get(
    "/api/assessments/domestic-epc/search?postcode=#{postcode}",
    accepted_responses,
    authenticate,
    auth_data
  )
end

def assessments_search_by_assessment_id(
  assessment_id, accepted_responses = [200], authenticate = true, auth_data = nil
)
  assertive_get(
    "/api/assessments/domestic-epc/search?assessment_id=#{assessment_id}",
    accepted_responses,
    authenticate,
    auth_data
  )
end

def assessments_search_by_street_name_and_town(
  street_name, town, accepted_responses = [200], authenticate = true, auth_data=nil
)
  assertive_get(
    "/api/assessments/domestic-epc/search?street_name=#{street_name}&town=#{
      town
    }",
    accepted_responses,
    authenticate,
    auth_data
  )
end

def assessors_search(
  postcode, qualification, accepted_responses = [200], authenticate = true, auth_data = nil
)
  assertive_get(
    "/api/assessors?postcode=#{postcode}&qualification=#{qualification}",
    accepted_responses,
    authenticate,
    auth_data
  )
end
