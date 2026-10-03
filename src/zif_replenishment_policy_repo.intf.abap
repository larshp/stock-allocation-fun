INTERFACE zif_replenishment_policy_repo PUBLIC.

  TYPES:
    BEGIN OF ty_material_plant,
      material TYPE marc-matnr,
      plant    TYPE marc-werks,
    END OF ty_material_plant.
  TYPES ty_material_plants TYPE STANDARD TABLE OF ty_material_plant
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_policy,
      lot_size_procedure            TYPE marc-disls,
      planning_calendar_id          TYPE marc-mrppp,
      procurement_type              TYPE marc-beskz,
      special_procurement_key       TYPE marc-sobsl,
      material                      TYPE marc-matnr,
      plant                         TYPE marc-werks,
      base_unit                     TYPE mara-meins,
      factory_calendar_id           TYPE t001w-fabkl,
      planned_delivery_days         TYPE marc-plifz,
      goods_receipt_processing_days TYPE marc-webaz,
      purchasing_processing_days    TYPE t399d-bzteK,
      minimum_base_quantity         TYPE marc-bstmi,
      maximum_base_quantity         TYPE marc-bstma,
      maximum_stock_quantity        TYPE marc-mabst,
      fixed_base_quantity           TYPE marc-bstfe,
      order_multiple_base_quantity  TYPE marc-bstrf,
      rounding_profile              TYPE marc-rdprf,
    END OF ty_policy.
  TYPES ty_policies TYPE STANDARD TABLE OF ty_policy WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_rounding_profile_key,
      plant            TYPE rdpr-werks,
      rounding_profile TYPE rdpr-rdprf,
    END OF ty_rounding_profile_key.
  TYPES ty_rounding_profile_keys TYPE SORTED TABLE OF
    ty_rounding_profile_key WITH UNIQUE KEY plant rounding_profile.
  TYPES:
    BEGIN OF ty_rounding_profile,
      plant              TYPE rdpr-werks,
      rounding_profile   TYPE rdpr-rdprf,
      level_number       TYPE rdpr-rdzae,
      threshold_quantity TYPE rdpr-bdmng,
      rounding_quantity  TYPE rdpr-vormg,
    END OF ty_rounding_profile.
  TYPES ty_rounding_profiles TYPE STANDARD TABLE OF ty_rounding_profile
    WITH EMPTY KEY.

  METHODS get_policies_bulk
    IMPORTING
      it_material_plants TYPE ty_material_plants
    RETURNING
      VALUE(rt_policies) TYPE ty_policies.

  METHODS get_rounding_profiles_bulk
    IMPORTING
      it_profile_keys    TYPE ty_rounding_profile_keys
    RETURNING
      VALUE(rt_profiles) TYPE ty_rounding_profiles.

ENDINTERFACE.
