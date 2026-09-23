INTERFACE zif_prod_comp_repo PUBLIC.

  TYPES:
    BEGIN OF ty_reservation_item,
      production_order   TYPE resb-aufnr,
      reservation_number TYPE resb-rsnum,
      reservation_item   TYPE resb-rspos,
      material           TYPE resb-matnr,
      plant              TYPE resb-werks,
      storage_location   TYPE resb-lgort,
      batch              TYPE resb-charg,
      movement_type      TYPE resb-bwart,
      required_date      TYPE resb-bdter,
      required_quantity  TYPE resb-bdmng,
      withdrawn_quantity TYPE resb-enmng,
      unit               TYPE resb-meins,
      is_deleted         TYPE resb-xloek,
      is_final_issue     TYPE resb-kzear,
    END OF ty_reservation_item.
  TYPES ty_reservation_items TYPE STANDARD TABLE OF ty_reservation_item
    WITH EMPTY KEY.

  METHODS get_components
    IMPORTING
      iv_production_order TYPE resb-aufnr
    RETURNING
      VALUE(rt_items)     TYPE ty_reservation_items.

ENDINTERFACE.
