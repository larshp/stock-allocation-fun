CLASS zcl_requirement_reader_vbap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_requirement_reader.

  PRIVATE SECTION.
    METHODS build_id
      IMPORTING
        iv_vbeln     TYPE vbap-vbeln
        iv_posnr     TYPE vbap-posnr
      RETURNING
        VALUE(rv_id) TYPE zif_requirement_reader=>ty_requirement-id.

    METHODS to_priority
      IMPORTING
        iv_lprio           TYPE vbap-lprio
      RETURNING
        VALUE(rv_priority) TYPE zif_requirement_reader=>ty_requirement-priority.

ENDCLASS.


CLASS zcl_requirement_reader_vbap IMPLEMENTATION.

  METHOD zif_requirement_reader~read_requirements.
    SELECT vbeln,
           posnr,
           matnr,
           werks,
           kwmeng,
           meins,
           edatu,
           abgru,
           lprio
      FROM vbap
      INTO TABLE @DATA(lt_vbap)
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
        AND abgru = ''
      ORDER BY edatu, vbeln, posnr.

    LOOP AT lt_vbap INTO DATA(ls_vbap).
      IF ls_vbap-kwmeng <= 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( id             = build_id( iv_vbeln = ls_vbap-vbeln
                                                 iv_posnr = ls_vbap-posnr )
                      priority       = to_priority( ls_vbap-lprio )
                      requested_date = ls_vbap-edatu
                      unit           = ls_vbap-meins
                      requested_qty  = ls_vbap-kwmeng ) TO rt_requirements.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_id.
    rv_id = |{ iv_vbeln }{ iv_posnr }|.
  ENDMETHOD.

  METHOD to_priority.
    rv_priority = iv_lprio.
    IF rv_priority <= 0.
      rv_priority = 1.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
