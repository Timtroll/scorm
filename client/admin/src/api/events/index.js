import serverHttp from '@/api/serverHttp'

export default class Event {

  constructor (userId) {
    this.userId = userId
  }

  async loadUsers (eventId) {
    if (!eventId) return
    return await serverHttp
      .query('/events/lesson_users', {id: eventId}, false, true)
  }

}
