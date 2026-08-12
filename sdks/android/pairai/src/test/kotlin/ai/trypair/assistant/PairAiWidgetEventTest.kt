package ai.trypair.assistant

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PairAiWidgetEventTest {

    @Test
    fun tryParse_widgetReady() {
        val event = PairAiWidgetEvent.tryParse(
            """{"type":"widget:ready","data":{"type":"widget:ready"},"origin":"http://localhost:3000","ts":"2026-08-12T21:00:00.000Z"}""",
        )
        assertNotNull(event)
        assertEquals("widget:ready", event!!.type)
        assertEquals("http://localhost:3000", event.origin)
    }

    @Test
    fun tryParse_unreadCount() {
        val event = PairAiWidgetEvent.tryParse(
            """{"type":"widget:unreadCount","data":{"type":"widget:unreadCount","count":3},"origin":"https://widgets-test.trypair.ai","ts":"2026-08-12T21:00:00.000Z"}""",
        )
        assertNotNull(event)
        assertEquals("widget:unreadCount", event!!.type)
        assertEquals(3, event.data["count"])
    }

    @Test
    fun tryParse_invalidJson_returnsNull() {
        assertNull(PairAiWidgetEvent.tryParse("not-json"))
    }

    @Test
    fun tryParse_missingType_returnsNull() {
        assertNull(PairAiWidgetEvent.tryParse("""{"data":{}}"""))
    }
}
