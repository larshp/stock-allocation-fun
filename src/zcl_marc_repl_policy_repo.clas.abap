CLASS zcl_marc_repl_policy_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_replenishment_policy_repo.
ENDCLASS.

CLASS zcl_marc_repl_policy_repo IMPLEMENTATION.

  METHOD zif_replenishment_policy_repo~get_policies_bulk.
    IF it_material_plants IS INITIAL.
      RETURN.
    ENDIF.

    SELECT marc~matnr AS material,
           marc~werks AS plant,
           marc~disls AS lot_size_procedure,
           marc~mrppp AS planning_calendar_id,
           marc~beskz AS procurement_type,
           marc~sobsl AS special_procurement_key,
           mara~meins AS base_unit,
           t001w~fabkl AS factory_calendar_id,
           marc~plifz AS planned_delivery_days,
           marc~webaz AS goods_receipt_processing_days,
           t399d~bzteK AS purchasing_processing_days,
           marc~bstmi AS minimum_base_quantity,
           marc~bstma AS maximum_base_quantity,
           marc~mabst AS maximum_stock_quantity,
           marc~bstfe AS fixed_base_quantity,
           marc~bstrf AS order_multiple_base_quantity,
           marc~rdprf AS rounding_profile
      FROM marc
      INNER JOIN mara
        ON mara~matnr = marc~matnr
      LEFT OUTER JOIN t001w
        ON t001w~werks = marc~werks
      LEFT OUTER JOIN t399d
        ON t399d~werks = marc~werks
      FOR ALL ENTRIES IN @it_material_plants
      WHERE marc~matnr = @it_material_plants-material
        AND marc~werks = @it_material_plants-plant
      INTO CORRESPONDING FIELDS OF TABLE @rt_policies.
  ENDMETHOD.

  METHOD zif_replenishment_policy_repo~get_rounding_profiles_bulk.
    IF it_profile_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT rdpr~werks AS plant,
           rdpr~rdprf AS rounding_profile,
           rdpr~rdzae AS level_number,
           rdpr~bdmng AS threshold_quantity,
           rdpr~vormg AS rounding_quantity
      FROM rdpr
      FOR ALL ENTRIES IN @it_profile_keys
      WHERE rdpr~werks = @it_profile_keys-plant
        AND rdpr~rdprf = @it_profile_keys-rounding_profile
      INTO CORRESPONDING FIELDS OF TABLE @rt_profiles.
  ENDMETHOD.

ENDCLASS.
