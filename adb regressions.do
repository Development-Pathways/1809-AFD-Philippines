
* outcome variables used for regressions
cantril_ladder self_poverty harvest_php_rice harvest_php_corn harvest_php_veg crop_harvest_php total_nb_nonfarm_assets farm_asset_spend_1y_php total_nb_farm_assets ///
any_hunger_3mo hunger_frequent fies fies_raw hh_average_fcs_score hh_average_fcs_poor hh_average_fcs_borderline hh_average_fcs_acceptable adult_average_fcs_score adult_average_fcs_poor adult_average_fcs_borderline adult_average_fcs_acceptable male_adult_fcs_score male_adult_fcs_poor male_adult_fcs_borderline male_adult_fcs_acceptable female_adult_fcs_score female_adult_fcs_poor female_adult_fcs_borderline female_adult_fcs_acceptable adult_avg_fcs_cereal adult_avg_fcs_pulses adult_avg_fcs_vegetable adult_avg_fcs_fruit adult_avg_fcs_oil_fats adult_avg_fcs_meat adult_avg_fcs_milk adult_avg_fcs_sugar child_average_fcs_score child_average_fcs_poor child_average_fcs_borderline child_average_fcs_acceptable fcs_grain_little fcs_tubers_little fcs_pulses_little fcs_green_veg_little fcs_vit_a_little fcs_other_veg_little fcs_fruit_little fcs_meat_little fcs_fish_little fcs_milk_little fcs_eggs_little fcs_sugar_little fcs_oil_little fcs_nuts_little fcs_condiments_little ///
received_train_nutrition quiz_index_correct quiz_share_correct total_food_1mo_php total_food_1mo_php_ln total_food_spend_1mo total_food_inkind_1mo  total_food_gift_1mo total_food_1mo_php_pc total_food_1mo_php_ln_pc expenses_1 expenses_2 expenses_3 expenses_4 expenses_5 expenses_6 expenses_7 expenses_8 expenses_9 expenses_10 expenses_11 expenses_12 expenses_13 expenses_14 expenses_15 expenses_16 tot_nonfood_exp any_borrowing_6mo any_borrowing_food_6mo current_out_bal largest_debt_6mo savings_php wages_1_mo_total hh_income_1_mo hh_income_1_mo_pc ln_hh_income_1_mo ln_hh_income_1_mo_pc purchased_1 purchased_2 purchased_3 purchased_4 purchased_5 purchased_6 purchased_7 purchased_8 purchased_9 purchase_1_kadiwa tot_transport_duration_1 q10_4_4_1 tot_transport_cost_1 q10_4_5_1 resilience_climate_1 resilience_climate_2 resilience_climate_3 resilience_climate_4 

* other variables used for regression
 treatment // explanatory var
 endline // endline only 
 pair_rank // fixed effects
 clustervar // cluster 
 farming_rice_at_baseline farming_corn_at_baseline farming_veg_at_baseline farming_at_baseline purchased_1_baseline /// condition on baseline characteristic
 INTNO // household level fixed effects
 larger_households max_presence_child_05 // condition on hh characteristics 
 meal_planner_respond // condition on respondent 
 MUN // condition on location 
 dummy_4p_any // condition on 4P receipt (either base or end)
 cshock_since_baseline // condition on experience of shocks
 offered_wg // didn't receive treatment but was offered, didn't receive treatment and wasn't offered ?
 
 
 
 
 
 
 