CLASS zcl_marc_repl_policy_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_replenishment_policy_repo.
ENDCLASS.

CLASS zcl_marc_repl_policy_repo IMPLEMENTATION.

  METHOD zif_replenishment_policy_repo~get_policies_bulk.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mara-matnr,
      END OF ty_material_key,
      ty_material_keys TYPE SORTED TABLE OF ty_material_key
        WITH UNIQUE KEY material,
      BEGIN OF ty_plant_key,
        plant TYPE t001w-werks,
      END OF ty_plant_key,
      ty_plant_keys TYPE SORTED TABLE OF ty_plant_key
        WITH UNIQUE KEY plant,
      BEGIN OF ty_base_unit,
        material  TYPE mara-matnr,
        base_unit TYPE mara-meins,
      END OF ty_base_unit,
      ty_base_units TYPE HASHED TABLE OF ty_base_unit
        WITH UNIQUE KEY material,
      BEGIN OF ty_factory_calendar,
        plant               TYPE t001w-werks,
        factory_calendar_id TYPE t001w-fabkl,
      END OF ty_factory_calendar,
      ty_factory_calendars TYPE HASHED TABLE OF ty_factory_calendar
        WITH UNIQUE KEY plant,
      BEGIN OF ty_purchasing_days,
        plant                      TYPE t399d-werks,
        purchasing_processing_days TYPE t399d-bzteK,
      END OF ty_purchasing_days,
      ty_purchasing_days_tab TYPE HASHED TABLE OF ty_purchasing_days
        WITH UNIQUE KEY plant.
    DATA lt_material_plants TYPE
      zif_replenishment_policy_repo=>ty_material_plants.
    DATA lt_material_keys TYPE ty_material_keys.
    DATA lt_plant_keys TYPE ty_plant_keys.
    DATA lt_marc_policies TYPE zif_replenishment_policy_repo=>ty_policies.
    DATA lt_base_units TYPE ty_base_units.
    DATA lt_factory_calendars TYPE ty_factory_calendars.
    DATA lt_purchasing_days TYPE ty_purchasing_days_tab.

    IF it_material_plants IS INITIAL.
      RETURN.
    ENDIF.
    lt_material_plants = it_material_plants.

    SELECT matnr AS material,
           werks AS plant,
           disls AS lot_size_procedure,
           mrppp AS planning_calendar_id,
           beskz AS procurement_type,
           sobsl AS special_procurement_key,
           plifz AS planned_delivery_days,
           webaz AS goods_receipt_processing_days,
           bstmi AS minimum_base_quantity,
           bstma AS maximum_base_quantity,
           mabst AS maximum_stock_quantity,
           bstfe AS fixed_base_quantity,
           bstrf AS order_multiple_base_quantity,
           rdprf AS rounding_profile
      FROM marc
      FOR ALL ENTRIES IN @lt_material_plants
      WHERE matnr = @lt_material_plants-material
        AND werks = @lt_material_plants-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_marc_policies.

    IF lt_marc_policies IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_marc_policies INTO DATA(ls_marc_policy).
      INSERT VALUE #( material = ls_marc_policy-material )
        INTO TABLE lt_material_keys.
      INSERT VALUE #( plant = ls_marc_policy-plant )
        INTO TABLE lt_plant_keys.
    ENDLOOP.

    SELECT matnr AS material,
           meins AS base_unit
      FROM mara
      FOR ALL ENTRIES IN @lt_material_keys
      WHERE matnr = @lt_material_keys-material
      INTO TABLE @lt_base_units.

    SELECT werks AS plant,
           fabkl AS factory_calendar_id
      FROM t001w
      FOR ALL ENTRIES IN @lt_plant_keys
      WHERE werks = @lt_plant_keys-plant
      INTO TABLE @lt_factory_calendars.

    SELECT werks AS plant,
           bzteK AS purchasing_processing_days
      FROM t399d
      FOR ALL ENTRIES IN @lt_plant_keys
      WHERE werks = @lt_plant_keys-plant
      INTO TABLE @lt_purchasing_days.

    LOOP AT lt_marc_policies INTO ls_marc_policy.
      READ TABLE lt_base_units INTO DATA(ls_base_unit)
        WITH TABLE KEY material = ls_marc_policy-material.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(ls_policy) = ls_marc_policy.
      ls_policy-base_unit = ls_base_unit-base_unit.
      READ TABLE lt_factory_calendars INTO DATA(ls_factory_calendar)
        WITH TABLE KEY plant = ls_marc_policy-plant.
      IF sy-subrc = 0.
        ls_policy-factory_calendar_id =
          ls_factory_calendar-factory_calendar_id.
      ENDIF.
      READ TABLE lt_purchasing_days INTO DATA(ls_plant_purchasing_days)
        WITH TABLE KEY plant = ls_marc_policy-plant.
      IF sy-subrc = 0.
        ls_policy-purchasing_processing_days =
          ls_plant_purchasing_days-purchasing_processing_days.
      ENDIF.
      APPEND ls_policy TO rt_policies.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_replenishment_policy_repo~get_rounding_profiles_bulk.
    IF it_profile_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT werks AS plant,
           rdprf AS rounding_profile,
           rdzae AS level_number,
           bdmng AS threshold_quantity,
           vormg AS rounding_quantity
      FROM rdpr
      FOR ALL ENTRIES IN @it_profile_keys
      WHERE werks = @it_profile_keys-plant
        AND rdprf = @it_profile_keys-rounding_profile
      INTO CORRESPONDING FIELDS OF TABLE @rt_profiles.
  ENDMETHOD.

ENDCLASS.
