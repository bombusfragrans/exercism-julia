using Dates
import Base: +, -

struct Clock
	t::Time
end

Clock(hr::Int,min::Int)::Clock = Clock(Dates.Time((mod = hr%24; mod < 0 ? 24 + mod : mod)) + Dates.Minute(min))

+(C::Clock,p::TimePeriod)::Clock = Clock(C.t + p)

-(C::Clock,p::TimePeriod)::Clock = Clock(C.t - p)

Base.show(io::IO,C::Clock) = Dates.format(io,C.t,dateformat"\"HH:MM\"")
