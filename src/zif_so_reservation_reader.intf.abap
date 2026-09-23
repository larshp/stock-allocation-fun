INTERFACE zif_so_reservation_reader PUBLIC.

  TYPES:
    BEGIN OF ty_item,
      reservation_number TYPE bapi2093_res_item_detail-res_no,
      item_number        TYPE bapi2093_res_item_detail-res_item,
      record_type        TYPE bapi2093_res_item_detail-res_type,
      status             TYPE bapi2093_res_item_detail-res_status,
      is_deleted         TYPE bapi2093_res_item_detail-delete_ind,
      movement_allowed   TYPE bapi2093_res_item_detail-movement,
      is_final_issue     TYPE bapi2093_res_item_detail-withdrawn,
      material           TYPE bapi2093_res_item_detail-material,
      plant              TYPE bapi2093_res_item_detail-plant,
      storage_location   TYPE bapi2093_res_item_detail-store_loc,
      batch              TYPE bapi2093_res_item_detail-batch,
      requirement_date   TYPE bapi2093_res_item_detail-req_date,
      required_quantity  TYPE bapi2093_res_item_detail-req_quan,
      base_unit          TYPE bapi2093_res_item_detail-base_uom,
      base_unit_iso      TYPE bapi2093_res_item_detail-base_uom_iso,
      withdrawn_quantity TYPE bapi2093_res_item_detail-withd_quan,
      entry_quantity     TYPE bapi2093_res_item_detail-quantity,
      entry_unit         TYPE bapi2093_res_item_detail-entry_uom,
    END OF ty_item.
  TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_result,
      items         TYPE ty_items,
      messages      TYPE zif_so_reservation_api=>ty_messages,
      is_successful TYPE abap_bool,
    END OF ty_result.

  METHODS read_reservation
    IMPORTING
      iv_reservation_number TYPE bapi2093_res_key-reserv_no
    RETURNING
      VALUE(rs_result)      TYPE ty_result.

ENDINTERFACE.
