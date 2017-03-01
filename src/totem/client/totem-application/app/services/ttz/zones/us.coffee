import ember from 'ember'

export default ember.Object.create
  title: "US (Common)"
  zones: [
    {
      iana:     "America/Puerto_Rico",
      friendly: "Puerto Rico (Atlantic)",
      alt:      ["atlantic"]
    },
    {
      iana:     "America/New_York",
      friendly: "New York (Eastern)",
      alt:      ["eastern"]
    },
    {
      iana:     "America/Chicago",
      friendly: "Chicago (Central)",
      alt:      ["central"]
    },
    {
      iana:     "America/Denver",
      friendly: "Denver (Mountain)",
      alt:      ["mountain"]
    },
    {
      iana:     "America/Los_Angeles",
      friendly: "Los Angeles (Pacific)",
      alt:      ["pacific"]
    },
    {
      iana:     "America/Anchorage",
      friendly: "Anchorage (Alaska)",
      alt:      ["alaska"]
    },
    {
      iana:     "Pacific/Honolulu",
      friendly: "Honolulu (Hawaii)",
      alt:      ["hawaii"]
    }
  ]
