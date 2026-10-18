require "test_helper"

class TicketTest < ActiveSupport::TestCase
  test "yeni bilet varsayılan olarak new durumunda ve 4 saatlik SLA ile oluşmalı" do
    freeze_time do
      ticket = Ticket.create!(
        title: "Fatura adresimi güncellemek istiyorum",
        description: "Yeni ofis adresimizi sisteme nasıl ekleyebilirim?",
        customer_email: "kullanici@example.com"
      )

      assert_equal "new", ticket.status
      assert_equal "normal", ticket.priority
      assert_in_delta 4.hours.from_now.to_i, ticket.sla_deadline.to_i, 1
      assert_nil ticket.resolved_at
    end
  end

  test "acil kelimesi içeren bilet otomatik urgent olmalı ve 1 saatlik SLA almalı" do
    freeze_time do
      ticket = Ticket.create!(
        title: "Acil: Ödeme sayfası çöktü",
        description: "Müşteriler ödeme adımında kritik hata alıyor.",
        customer_email: "acil@example.com"
      )

      assert_equal "new", ticket.status
      assert_equal "urgent", ticket.priority
      assert_in_delta 1.hour.from_now.to_i, ticket.sla_deadline.to_i, 1
    end
  end

  test "mark_as_open ve mark_as_solved durum geçişlerini doğru yapmalı ve resolved_at tarihini kaydetmeli" do
    ticket = Ticket.create!(
      title: "Rapor dışa aktarma sorusu",
      description: "CSV çıktısını nereden alabilirim?",
      customer_email: "rapor@example.com"
    )

    ticket.mark_as_open!
    assert_equal "open", ticket.reload.status
    assert_nil ticket.resolved_at

    freeze_time do
      ticket.mark_as_solved!
      assert_equal "solved", ticket.reload.status
      assert_not_nil ticket.resolved_at
      assert_in_delta Time.current.to_i, ticket.resolved_at.to_i, 1
    end
  end

  test "travel_to kullanarak SLA süresi dolduğunda sla_breached? true dönmeli" do
    ticket = Ticket.create!(
      title: "Genel bilgi talebi",
      description: "Paket yükseltme seçenekleri nelerdir?",
      customer_email: "bilgi@example.com"
    )

    assert_not ticket.sla_breached?

    travel_to 5.hours.from_now do
      assert ticket.sla_breached?
    end
  end

  test "bilet çözüldüğünde süre geçse bile sla_breached? false dönmeli" do
    ticket = Ticket.create!(
      title: "Sistem erişim sorunu",
      description: "Sayfa açılmıyor, hata veriyor.",
      customer_email: "destek@example.com"
    )

    ticket.mark_as_solved!

    travel_to 10.hours.from_now do
      assert_not ticket.sla_breached?
    end
  end
end
