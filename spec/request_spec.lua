local web = require("src/web")
local inspect = require("inspect")

describe("test http requests:", function()

  it("test simple request", function()

    local url = "http://example.com"
    local actual, err = web.request(url)
    local expectedStatus = 200
    assert.are.equal(expectedStatus, actual.status)

  end)

  it("test https request", function()
    local url = "https://example.com"
    local actual, err = web.request(url)
    local expectedStatus = 200
    assert.are.equal(expectedStatus, actual.status)
  end)

end)


