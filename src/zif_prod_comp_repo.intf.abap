INTERFACE zif_prod_comp_repo PUBLIC.

  TYPES:
    BEGIN OF ty_reservation_item,
      production_order          TYPE resb-aufnr,
      planned_order             TYPE resb-plnum,
      reservation_number        TYPE resb-rsnum,
      reservation_item          TYPE resb-rspos,
      sales_order_number        TYPE resb-kdauf,
      sales_order_item          TYPE resb-kdpos,
      sales_order_schedule_line TYPE resb-kdein,
      wbs_internal_id           TYPE resb-pspel,
      special_stock_indicator   TYPE resb-sobkz,
      requirement_type          TYPE resb-bdart,
      staging_indicator         TYPE resb-berkz,
      mrp_relevance             TYPE resb-no_disp,
      bom_item_number           TYPE resb-posnr,
      bom_item_text             TYPE resb-potx1,
      material                  TYPE resb-matnr,
      plant                     TYPE resb-werks,
      storage_location          TYPE resb-lgort,
      batch                     TYPE resb-charg,
      movement_type             TYPE resb-bwart,
      required_date             TYPE resb-bdter,
      required_quantity         TYPE resb-bdmng,
      withdrawn_quantity        TYPE resb-enmng,
      unit                      TYPE resb-meins,
      is_deleted                TYPE resb-xloek,
      is_final_issue            TYPE resb-kzear,
    END OF ty_reservation_item.
  TYPES ty_reservation_items TYPE STANDARD TABLE OF ty_reservation_item
    WITH EMPTY KEY.
  TYPES ty_production_orders TYPE STANDARD TABLE OF resb-aufnr WITH EMPTY KEY.
  TYPES ty_planned_orders TYPE STANDARD TABLE OF resb-plnum WITH EMPTY KEY.
  TYPES ty_open_quantity_pct TYPE p LENGTH 5 DECIMALS 2.
  TYPES:
    BEGIN OF ty_required_date_range,
      filter_from                    TYPE abap_bool,
      required_date_from             TYPE resb-bdter,
      filter_through                 TYPE abap_bool,
      required_date_through          TYPE resb-bdter,
      filter_bucket                  TYPE abap_bool,
      required_date_bucket           TYPE c LENGTH 1,
      required_date_horizon_days     TYPE i,
      as_of_date                     TYPE d,
      include_undated                TYPE abap_bool,
      filter_material                TYPE abap_bool,
      material                       TYPE resb-matnr,
      filter_plant                   TYPE abap_bool,
      plant                          TYPE resb-werks,
      filter_storage_location        TYPE abap_bool,
      storage_location               TYPE resb-lgort,
      filter_batch                   TYPE abap_bool,
      batch                          TYPE resb-charg,
      filter_movement_type           TYPE abap_bool,
      movement_type                  TYPE resb-bwart,
      filter_unit                    TYPE abap_bool,
      unit                           TYPE resb-meins,
      filter_sales_order_item        TYPE abap_bool,
      sales_order_number             TYPE resb-kdauf,
      sales_order_item               TYPE resb-kdpos,
      filter_sales_schedule_line     TYPE abap_bool,
      sales_order_schedule_line      TYPE resb-kdein,
      filter_special_stock_indicator TYPE abap_bool,
      special_stock_indicator        TYPE resb-sobkz,
      filter_requirement_type        TYPE abap_bool,
      requirement_type               TYPE resb-bdart,
      filter_staging_indicator       TYPE abap_bool,
      staging_indicator              TYPE resb-berkz,
      filter_mrp_relevance           TYPE abap_bool,
      mrp_relevance                  TYPE resb-no_disp,
      filter_bom_item                TYPE abap_bool,
      bom_item_number                TYPE resb-posnr,
      filter_wbs_internal_id         TYPE abap_bool,
      wbs_internal_id                TYPE resb-pspel,
      filter_reservation_number      TYPE abap_bool,
      reservation_number             TYPE resb-rsnum,
      filter_res_num_from            TYPE abap_bool,
      reservation_number_from        TYPE resb-rsnum,
      filter_res_num_through         TYPE abap_bool,
      reservation_number_through     TYPE resb-rsnum,
      filter_reservation_item        TYPE abap_bool,
      reservation_item               TYPE resb-rspos,
      filter_res_item_from           TYPE abap_bool,
      reservation_item_from          TYPE resb-rspos,
      filter_res_item_through        TYPE abap_bool,
      reservation_item_through       TYPE resb-rspos,
      filter_open_quantity_from      TYPE abap_bool,
      open_quantity_from             TYPE resb-bdmng,
      filter_open_quantity_through   TYPE abap_bool,
      open_quantity_through          TYPE resb-bdmng,
      filter_required_qty_from       TYPE abap_bool,
      required_quantity_from         TYPE resb-bdmng,
      filter_required_qty_through    TYPE abap_bool,
      required_quantity_through      TYPE resb-bdmng,
      filter_withdrawn_qty_from      TYPE abap_bool,
      withdrawn_quantity_from        TYPE resb-enmng,
      filter_withdrawn_qty_through   TYPE abap_bool,
      withdrawn_quantity_through     TYPE resb-enmng,
      filter_open_qty_pct_from       TYPE abap_bool,
      open_qty_pct_from              TYPE ty_open_quantity_pct,
      filter_open_qty_pct_through    TYPE abap_bool,
      open_qty_pct_through           TYPE ty_open_quantity_pct,
      filter_withdrawn_pct_from      TYPE abap_bool,
      withdrawn_pct_from             TYPE ty_open_quantity_pct,
      filter_withdrawn_pct_through   TYPE abap_bool,
      withdrawn_pct_through          TYPE ty_open_quantity_pct,
    END OF ty_required_date_range.

  METHODS get_components
    IMPORTING
      iv_production_order    TYPE resb-aufnr
      is_required_date_range TYPE ty_required_date_range OPTIONAL
    RETURNING
      VALUE(rt_items)        TYPE ty_reservation_items.

  METHODS get_components_bulk
    IMPORTING
      it_production_orders   TYPE ty_production_orders
      is_required_date_range TYPE ty_required_date_range OPTIONAL
    RETURNING
      VALUE(rt_items)        TYPE ty_reservation_items.

  METHODS get_planned_comp
    IMPORTING
      iv_planned_order       TYPE resb-plnum
      is_required_date_range TYPE ty_required_date_range OPTIONAL
    RETURNING
      VALUE(rt_items)        TYPE ty_reservation_items.

  METHODS get_planned_comp_bulk
    IMPORTING
      it_planned_orders      TYPE ty_planned_orders
      is_required_date_range TYPE ty_required_date_range OPTIONAL
    RETURNING
      VALUE(rt_items)        TYPE ty_reservation_items.

ENDINTERFACE.
