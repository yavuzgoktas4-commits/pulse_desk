module ApplicationHelper
  def remaining_sla_text(ticket)
    return "Çözüldü (#{ticket.resolved_at&.strftime('%d.%m.%Y %H:%M') || 'Tamamlandı'})" if ticket.status == "solved"
    return "SLA tanımlanmadı" if ticket.sla_deadline.nil?

    diff_seconds = (ticket.sla_deadline - Time.current).to_i

    if diff_seconds < 0
      overdue_minutes = (diff_seconds.abs / 60.0).ceil
      if overdue_minutes >= 60
        "İhlal Edildi (#{overdue_minutes / 60} sa #{overdue_minutes % 60} dk gecikti)"
      else
        "İhlal Edildi (#{overdue_minutes} dk gecikti)"
      end
    else
      remaining_minutes = (diff_seconds / 60.0).ceil
      if remaining_minutes >= 60
        hours = remaining_minutes / 60
        mins = remaining_minutes % 60
        mins > 0 ? "Kalan: #{hours} saat #{mins} dk" : "Kalan: #{hours} saat"
      else
        "Kalan: #{remaining_minutes} dk"
      end
    end
  end

  def sla_badge_classes(ticket)
    if ticket.status == "solved"
      "bg-emerald-50 text-emerald-700 ring-1 ring-inset ring-emerald-600/20"
    elsif ticket.sla_breached?
      "bg-red-50 text-red-700 ring-1 ring-inset ring-red-600/30 font-semibold"
    elsif ticket.sla_deadline.present? && (ticket.sla_deadline - Time.current) <= 1.hour
      "bg-amber-50 text-amber-800 ring-1 ring-inset ring-amber-600/25 font-medium"
    else
      "bg-slate-100 text-slate-700 ring-1 ring-inset ring-slate-500/20"
    end
  end

  def status_badge_classes(status)
    case status
    when "new"
      "bg-sky-50 text-sky-700 ring-1 ring-inset ring-sky-600/20"
    when "open"
      "bg-amber-50 text-amber-800 ring-1 ring-inset ring-amber-600/20"
    when "solved"
      "bg-emerald-50 text-emerald-700 ring-1 ring-inset ring-emerald-600/20"
    else
      "bg-slate-100 text-slate-700 ring-1 ring-inset ring-slate-500/20"
    end
  end

  def status_dot_classes(status)
    case status
    when "new" then "bg-sky-500"
    when "open" then "bg-amber-500"
    when "solved" then "bg-emerald-500"
    else "bg-slate-400"
    end
  end

  def status_label(status)
    case status
    when "new" then "Yeni (New)"
    when "open" then "Açık (Open)"
    when "solved" then "Çözüldü (Solved)"
    else status.to_s.titleize
    end
  end

  def priority_badge_classes(priority)
    case priority
    when "urgent"
      "bg-red-50 text-red-700 ring-1 ring-inset ring-red-600/25 font-semibold"
    when "high"
      "bg-orange-50 text-orange-700 ring-1 ring-inset ring-orange-600/25 font-semibold"
    when "medium", "normal"
      "bg-indigo-50 text-indigo-700 ring-1 ring-inset ring-indigo-600/20 font-medium"
    when "low"
      "bg-slate-100 text-slate-700 ring-1 ring-inset ring-slate-500/20 font-medium"
    else
      "bg-slate-100 text-slate-700 ring-1 ring-inset ring-slate-500/20"
    end
  end

  def priority_dot_classes(priority)
    case priority
    when "urgent" then "bg-red-500"
    when "high" then "bg-orange-500"
    when "medium", "normal" then "bg-indigo-500"
    when "low" then "bg-slate-400"
    else "bg-slate-400"
    end
  end

  def priority_label(priority)
    case priority
    when "urgent" then "Acil (Urgent)"
    when "high" then "Yüksek (High)"
    when "medium" then "Orta (Medium)"
    when "normal" then "Normal"
    when "low" then "Düşük (Low)"
    else priority.to_s.titleize
    end
  end
end
