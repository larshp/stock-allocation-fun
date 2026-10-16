CLASS zcl_alloc_volume DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             row_count       TYPE i,
             field_count     TYPE i,
             bytes_per_field TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_estimate,
             total_bytes         TYPE i,
             total_kb            TYPE i,
             total_mb            TYPE i,
             records_per_package TYPE i,
           END OF ty_estimate.

    METHODS estimate
      IMPORTING
        is_input           TYPE ty_input
        iv_target_mb       TYPE i
      RETURNING
        VALUE(rs_estimate) TYPE ty_estimate.

ENDCLASS.


CLASS zcl_alloc_volume IMPLEMENTATION.

  METHOD estimate.
    DATA lv_bytes_per_row TYPE i.
    DATA lv_package_bytes TYPE i.

    IF is_input-row_count <= 0.
      RETURN.
    ENDIF.

    lv_bytes_per_row = is_input-field_count * is_input-bytes_per_field.
    rs_estimate-total_bytes = is_input-row_count * lv_bytes_per_row.
    rs_estimate-total_kb = rs_estimate-total_bytes DIV 1024.
    rs_estimate-total_mb = rs_estimate-total_kb DIV 1024.
    rs_estimate-records_per_package = is_input-row_count.

    IF iv_target_mb <= 0 OR lv_bytes_per_row <= 0.
      RETURN.
    ENDIF.

    lv_package_bytes = iv_target_mb * 1024 * 1024.
    rs_estimate-records_per_package = lv_package_bytes DIV lv_bytes_per_row.

    IF rs_estimate-records_per_package < 1.
      rs_estimate-records_per_package = 1.
      RETURN.
    ENDIF.

    IF rs_estimate-records_per_package > is_input-row_count.
      rs_estimate-records_per_package = is_input-row_count.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
