#!/usr/bin/ruby

module Adapters

  #--------------------------
  #
  # @class PaymentToCsvAdapter
  #
  # @desc Responsibility: Takes a Payment and creates (adapts it to) CSV
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2020-02-20
  #
  #
  #--------------------------
  class PaymentToCsvAdapter < AbstractAdapter


    def target_class
      CsvRow
    end


    def set_target_attributes(target)
      co_name = ''
      co_num = ''
      amount = 0

      payment = @adaptee
      target << payment.id
      target << quote(payment.user.full_name)
      target << payment.user.email

      if payment.payment_type == Payment::PAYMENT_TYPE_BRANDING
        co_name = payment.company.name
        co_num = payment.company.company_number
        amount = SHF_BRANDING_FEE / 100
      else
        amount = SHF_MEMBER_FEE / 100
      end

      target << amount

      target << quote(co_name)
      target << co_num

      target << payment.payment_type

      target << quote(payment.start_date)
      target << quote(payment.expire_date)

      target << quote(payment.created_at.strftime('%F'))

      target << payment.status
      target << payment.hips_id

      target << quote(payment.notes)

      target
    end


  end

end
