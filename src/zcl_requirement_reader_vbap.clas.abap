CLASS zcl_requirement_reader_vbap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_requirement_reader.

  PRIVATE SECTION.
    TYPES ty_vbeln TYPE c LENGTH 10.
    TYPES ty_posnr TYPE n LENGTH 6.
    TYPES ty_lprio TYPE n LENGTH 2.

    METHODS build_id
      IMPORTING
        iv_vbeln     TYPE ty_vbeln
        iv_posnr     TYPE ty_posnr
      RETURNING
        VALUE(rv_id) TYPE zif_requirement_reader=>ty_requirement-id.

    METHODS to_priority
      IMPORTING
        iv_lprio           TYPE ty_lprio
      RETURNING
        VALUE(rv_priority) TYPE zif_requirement_reader=>ty_requirement-priority.

ENDCLASS.


CLASS zcl_requirement_reader_vbap IMPLEMENTATION.

  METHOD zif_requirement_reader~read_requirements.
    SELECT item~vbeln,
           item~posnr,
           item~matnr,
           item~werks,
           item~kwmeng,
           item~meins,
           head~vdatu,
           item~abgru,
           item~lprio
      FROM vbap AS item
      INNER JOIN vbak AS head ON head~vbeln = item~vbeln
      INTO TABLE @DATA(lt_items)
      WHERE item~matnr = @iv_matnr
        AND item~werks = @iv_werks
        AND item~abgru = ''
      ORDER BY head~vdatu, item~vbeln, item~posnr.

    LOOP AT lt_items INTO DATA(ls_item).
      IF ls_item-kwmeng <= 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( id             = build_id( iv_vbeln = ls_item-vbeln
                                                 iv_posnr = ls_item-posnr )
                      priority       = to_priority( ls_item-lprio )
                      requested_date = ls_item-vdatu
                      unit           = ls_item-meins
                      requested_qty  = ls_item-kwmeng ) TO rt_requirements.
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
