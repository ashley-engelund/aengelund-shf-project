Feature: Show companies on a map

  As a user of the system
  So that I can see where companies are located easily
  Show the companies on a map

  PivotalTracker:

  Background:

    Given the following users exists
      | email                                  | admin | member |
      | fred-groomer-walker@kista.com          |       | true   |
      | johngroomer@celsius-gs-stockholm.com   |       | true   |
      | anna-groomer@rehnsgatanstockholm.com   |       | true   |
      | emma-walker@lidingo1.com               |       | true   |
      | norbert-groomer-walker@norrbotten1.com |       | true   |
      | admin@shf.se                           | true  |        |


    And the following business categories exist
      | name         |
      | Groomer      |
      | Psychologist |
      | Trainer      |
      | Walker       |


    And the following regions exist:
      | name            |
      | Stockholm       |
      | Norrbotten      |
      | Uppsala         |
      | Västra Götaland |

    And the following kommuns exist:
      | name        |
      | Alingsås    |
      | Bromölla    |
      | Laxå        |
      | Östersund   |
      | Enköping    |
      | Ale         |
      | Trollhättan |
      | Uppsala     |
      | Stockholm   |


    # Real addresses and their distance to the center of Stockholm [59.3251172, 18.0710935]
    # Geocoder::Calculations.distance_between([59.3251172, 18.0710935], [location2_lat, location2_long])
    And the following companies exist:
      | name                  | company_number | email                         | region          | kommun      | street_address       | post_code | city        | latitude   | longitude  | dist. to Stockholm |
      | CelsiusgatanStockholm | 2120000142     | hello@CelsiusGStockholm.com   | Stockholm       | Stockholm   | Celsiusgatan 6       | 112 30    | Stockholm   | 59.3329232 | 18.0392789 | 1.7094179715481526 |
      | RehnsgatanStockholm   | 5562252998     | hello@RehnsgatanStockholm.com | Stockholm       |             | Rehnsgatan 15        | 113 57    | Stockholm   | 59.342636  | 18.0594449 | 1.568314694498913  |
      | ÅrstaStockholm1       | 5872150379     | hello@ArstaStockholm2.com     | Stockholm       | Stockholm   | Svärdlångsvägen 11 C | 120 60    | Årsta       | 59.3015117 | 18.0397772 | 3.497852287750966  |
      | ÅrstaStockholm2       | 8728875504     | hello@ArstaStockholm2.com     | Stockholm       | Stockholm   | Årstavägen 57        | 120 54    | Årsta       | 59.2970298 | 18.0503637 | 3.73672833055599   |
      | Lidingö1              | 5569467466     | hello@Lidingo1.com            | Stockholm       |             | Bodalsvägen 15       | 181 36    | Lidingö     | 59.3498151 | 18.1398528 | 4.639507706089959  |
      | Bromma VG             | 9475077674     | hello@bromma.com              | Västra Götaland | Ale         | Ulvsundavägen 146    | 167 68    | Bromma      | 59.3414953 | 17.9613089 | 6.232155589244837  |
      | Kista Co              | 5560360793     | hello@kista.com               | Stockholm       |             | AKALLALÄNKEN 10      | 164 74    | Kista       | 59.4166931 | 17.9057914 | 13.3947988589553   |
      | Lilli1Uppsala         | 9360289459     | hello@Lilli1.com              | Uppsala         | Enköping    | Skolvägen 2          | 745 97    | Enköping    | 59.5590857 | 17.2471371 | 52.99909174906389  |
      | Lilli2Uppsala         | 9267816362     | hello@Lilli2.com              | Uppsala         | Enköping    | Prästvägen 4-22      | 745 97    | Enköping    | 59.5588239 | 17.2427471 | 53.20283552862525  |
      | FyrislundUppsala      | 9243957975     | hello@FyrislundUpp.com        | Uppsala         | Uppsala     | Verkstadsgatan 16    | 753 23    | Fyrislund   | 59.8473772 | 17.6897638 | 61.424412158596276 |
      | SaabHatten VG         | 9074668568     | hello@saab.com                | Västra Götaland | Trollhättan | Åkerssjövägen 18     | 461 55    | Trollhättan | 58.2721537 | 12.2764608 | 353.59496003517245 |
      | Alingsås VG           | 8909248752     | hello@Alingsas.com            | Västra Götaland | Alingsås    | Drottninggatan 26    | 441 30    | Alingsås    | 57.9302268 | 12.5425136 | 355.49614523798846 |
      | Harplinge2            | 8822107739     | hello@Harplinge2.com          |                 |             | Tranevallsvägen 2    | 305 60    | Harplinge   | 56.7435986 | 12.730684  | 425.4823948312603  |
      | Harplinge4            | 8764985894     | hello@Harplinge3.com          |                 |             | Kvarnliden 8         | 310 40    | Harplinge   | 56.7442943 | 12.72646   | 425.8036350054861  |
      | Harplinge3            | 8616006592     | hello@Harplinge3.com          |                 |             | Kvarnliden 10        | 310 40    | Harplinge   | 56.7442943 | 12.7264595 | 425.8036566862569  |
      | Harplinge1            | 5569767808     | hello@Harplinge1.com          |                 |             | Skintabyvägen 1      | 305 60    | Harplinge   | 56.7415584 | 12.7222458 | 426.0079519349758  |
      | Norrbotten1           | 8589182768     | hello@Norrbotten1.com         | Norbotten       |             | Industrivägen 3      | 957 32    | Övertorneå  | 66.3900454 | 23.6550021 | 833.9008890081374  |


    And the following applications exist:
      | user_email                             | company_number | state    | categories      |
      | fred-groomer-walker@kista.com          | 5560360793     | accepted | Groomer, Walker |
      | johngroomer@celsius-gs-stockholm.com   | 2120000142     | accepted | Groomer         |
      | anna-groomer@rehnsgatanstockholm.com   | 5562252998     | accepted | Groomer         |
      | emma-walker@lidingo1.com               | 5569467466     | accepted | Walker          |
      | norbert-groomer-walker@norrbotten1.com | 8589182768     | accepted | Groomer, Walker |


    And the following payments exist
      | user_email                             | start_date | expire_date | payment_type | status | hips_id | company_number |
      | fred-groomer-walker@kista.com          | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 5560360793     |
      | johngroomer@celsius-gs-stockholm.com   | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 2120000142     |
      | anna-groomer@rehnsgatanstockholm.com   | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 5562252998     |
      | emma-walker@lidingo1.com               | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 5569467466     |
      | norbert-groomer-walker@norrbotten1.com | 2018-01-01 | 2018-12-31  | branding_fee | betald | none    | 8589182768     |



    Given the date is set to "2018-10-01"


  @selenium
  Scenario: Visitor sees the companies on the map and the Show Near Me control
    Given I am logged out
    And I am on the "all companies" page
    Then I should see the map
    And I should see the Show Near Me control on the map
    And I should see 5 company markers on the map

