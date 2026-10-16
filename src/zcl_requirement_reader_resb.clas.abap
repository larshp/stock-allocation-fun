CLASS zcl_requirement_reader_resb DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_requirement_reader.

  PRIVATE SECTION.
    METHODS build_id
      IMPORTING
        iv_rsnum     TYPE resb-rsnum
        iv_rspos     TYPE resb-rspos
      RETURNING
        VALUE(rv_id) TYPE zif_requirement_reader=>ty_requirement-id.

ENDCLASS.


CLASS zcl_requirement_reader_resb IMPLEMENTATION.

  METHOD zif_requirement_reader~read_requirements.
    DATA lv_open_qty TYPE zif_requirement_reader=>ty_quantity.

    SELECT rsnum,
           rspos,
           bdter,
           bdmng,
           enmng
      FROM resb
      INTO TABLE @DATA(lt_resb)
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
        AND xloek <> 'X'
        AND kzear <> 'X'
      ORDER BY bdter, rsnum, rspos.

    LOOP AT lt_resb INTO DATA(ls_resb).
      lv_open_qty = ls_resb-bdmng - ls_resb-enmng.
      IF lv_open_qty <= 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( id             = build_id( iv_rsnum = ls_resb-rsnum
                                                 iv_rspos = ls_resb-rspos )
                      priority       = 1
                      requested_date = ls_resb-bdter
                      requested_qty  = lv_open_qty ) TO rt_requirements.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_id.
    rv_id = |{ iv_rsnum }{ iv_rspos }|.
  ENDMETHOD.

ENDCLASS.
