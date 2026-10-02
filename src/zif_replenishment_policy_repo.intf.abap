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
      fixed_base_quantity           TYPE marc-bstfe,
      order_multiple_base_quantity  TYPE marc-bstrf,
    END OF ty_policy.
  TYPES ty_policies TYPE STANDARD TABLE OF ty_policy WITH EMPTY KEY.

  METHODS get_policies_bulk
    IMPORTING
      it_material_plants TYPE ty_material_plants
    RETURNING
      VALUE(rt_policies) TYPE ty_policies.

ENDINTERFACE.
