id: 1, 
authable_type: "Thinkspace::Casespace::Phase", 
authable_id: 1, 
user_id: 2, 
title: "IRAT Assessment", 
state: "active", 
settings: 
  {
    "ra_type"=>"irat", 
    "submit"=>
      {
        "transition_user_team_members_on_last_user_submit"=>true
      }, 
    "questions"=>
      {
        "type"=>"multiple_choice", 
        "random"=>false, 
        "ifat"=>true, 
        "justification"=>true
      }, 
    "scoring"=>
      {
        "correct"=>3, 
        "attempted"=>1, 
        "no_answer"=>0, 
        "incorrect_attempt"=>-1
      }
  }, 
questions: 
  [
    {
      "id"=>"ra_1_1", 
      "question"=>"Question 1", 
      "choices"=>
        [
          {
            "id"=>"1", 
            "label"=>"Choice 1"
          }, 
          {
            "id"=>"2", 
            "label"=>"Choice 2"
          }, 
          {
            "id"=>"3", 
            "label"=>"Choice 3"
          }, 
          {
            "id"=>"4", 
            "label"=>"Choice 4"
          }
        ]
    }, 
    {
      "id"=>"ra_1_2", 
      "question"=>"Question 2", 
      "choices"=>
        [
          {
            "id"=>"1", 
            "label"=>"Choice 1"
          }, 
          {
            "id"=>"2", 
            "label"=>"Choice 2"
          }, 
          {
            "id"=>"3", 
            "label"=>"Choice 3"
          }, 
          {
            "id"=>"4", 
            "label"=>"Choice 4"
          }
        ]
      }, 
      {
        "id"=>"ra_1_3", 
        "question"=>"Question 3", 
        "choices"=>
          [
            {
              "id"=>"1", 
              "label"=>"Choice 1"
            }, 
            {
              "id"=>"2", 
              "label"=>"Choice 2"
            }, 
            {
              "id"=>"3", 
              "label"=>"Choice 3"
            }, 
            {
              "id"=>"4", 
              "label"=>"Choice 4"
            }
          ]
        }
  ], 
answers: 
  {
    "correct"=>
      {
        "ra_1_1"=>"1", 
        "ra_1_2"=>"2", 
        "ra_1_3"=>"3"
      }
  }, 
created_at: "2017-04-11 17:02:40", 
updated_at: "2017-04-11 17:02:40"