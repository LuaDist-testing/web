local web = require("src/web")

describe("test http requests:", function()

  local expected = { status = 200, body = 'Example content\n' }

  it("test #HTTP #GET request", function()
    local url = "http://tester.deviant.guru/get"
    local actual, err = web.request(url)
    if err then actual = {} end
    assert.are.equal(expected.status, actual.status)
    assert.are.equal(expected.body, actual.body) 
  end)

  it("test #HTTP #GET request on non-standard port", function()
    local url = "http://tester.deviant.guru:8088/get"
    local actual, err = web.request(url)
    if err then actual = {} end
    assert.are.equal(expected.status, actual.status)
    assert.are.equal(expected.body, actual.body)
  end) 

  it("test #HTTPS #GET request", function()
    local url = "https://tester.deviant.guru:444/get"
    local actual, err = web.request(url)
    if err then actual = {} end
    assert.are.equal(expected.status, actual.status)
    assert.are.equal(expected.body, actual.body)
  end)

  it("test #HTTP #POST request", function()
    local expected = { status = 200, body = 'Hi there\n' }
    local url = "http://tester.deviant.guru/post"
    local actual, err = web.request(url, { method = "POST", body = "Hi there" })
    if err then actual = {} end
    assert.are.equal(expected.status, actual.status)
    assert.are.equal(expected.body, actual.body)
  end)

  it("test #QUERY args and response statuses", function()
    local expected = { status = 451 }
    local url = "https://tester.deviant.guru:444/query?status=451"
    local actual, err = web.request(url)
    if err then actual = {} end
    assert.are.equal(expected.status, actual.status)
  end)

  it("test #UNIX socket request", function()
    local expected = { status = 200 }
    local url = "unix:/tmp/docker.sock:/containers/json"
    local actual, err = web.request(url)
    if err then actual = {} end
    assert.are.equal(expected.status, actual.status)
  end)

end)
